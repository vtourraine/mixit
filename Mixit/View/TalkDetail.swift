//
//  TalkDetail.swift
//  mixit
//
//  Created by Vincent Tourraine on 04/08/2022.
//  Copyright © 2022-2025 Studio AMANgA. All rights reserved.
//

import SwiftUI

struct TalkDetail: View {
    let nameFormatter = PersonNameComponentsFormatter()
    let timeIntervalFormatter: DateIntervalFormatter = {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .none
        return formatter
    }()

    @ObservedObject var talk: Talk
    @State var showAddEventModal = false

    var shareItems: [Any] {
        get {
            if let title = talk.title, let year = talk.year, let slug = talk.slug,
               let url = URL(string: "https://mixitconf.org/\(year)/\(slug)") {
                return [title, url]
            }
            else {
                return [URL(string: "https://mixitconf.org/")!]
            }
        }
    }

    @State private var isSharePresented: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if let title = talk.title {
                    Text(title)
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer(minLength: 10)

                if let language = talk.localizedLanguage,
                   let format = talk.format {
                    HStack(spacing: 0) {
                        Text(format.localizedCapitalized)
                            .bold()
                        Text(" • ")
                        Text(language)
                    }
                    .font(.body)

                    Spacer(minLength: 30)
                }

                HStack {
                    if let startDate = talk.startDate, let endDate = talk.endDate {
                        TalkDetailItem(text: "\(Talk.dayFormatter.string(from: startDate).localizedCapitalized)\n\(timeIntervalFormatter.string(from: startDate, to: endDate))", systemImageName: "clock")
                    }
                    if let room = talk.room {
                        let formattedRoom = NSLocalizedString(room, tableName: "Rooms", comment: "")
                        TalkDetailItem(text: formattedRoom, systemImageName: "mappin")
                    }
                    else {
                        TalkDetailItem(text: "Not announced yet", systemImageName: "ellipsis")
                    }
                }

                Spacer(minLength: 30)

                ForEach(talk.fetchSpeakers()) { speaker in
                    SpeakerView(nameFormatter: nameFormatter, speaker: speaker)
                    Spacer(minLength: 10)
                }

                Spacer(minLength: 20)

                if let effectiveSummary = talk.effectiveSummary {
                    Text(effectiveSummary)
                        .font(.body).italic()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer(minLength: 20)
                }

                if let effectiveDescription = talk.effectiveDescription {
                    Text(effectiveDescription)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
            .textSelection(.enabled)
            .frame(minWidth: 300, maxWidth: 600, alignment: .leading)
        }
#if os(iOS)
        .sheet(isPresented: $showAddEventModal){
            AddEvent(talk: talk)
        }
#endif
        .toolbar {
#if os(iOS)
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    showAddEventModal.toggle()
                } label: {
                    Label("Add to Calendar", systemImage: "calendar.badge.plus")
                }
                Button {
                    talk.toggleFavorited()
                } label: {
                    Label(talk.isFavorited ? "Remove from Favorites" : "Add to Favorites", systemImage: talk.isFavorited ? "star.fill" : "star")
                }
                Button {
                    self.isSharePresented = true
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .sheet(isPresented: $isSharePresented, onDismiss: {
                }, content: {
                    ActivityViewController(activityItems: shareItems)
                })
            }
#endif
#if os(macOS)
            ToolbarItem {
                Button {
                    talk.toggleFavorited()
                } label: {
                    Label("Add to Favorites", systemImage: (talk.favorited?.boolValue ?? false) ? "star.fill" : "star")
                }
            }
            ToolbarItem {
                Button {
                    self.isSharePresented = true
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .background(SharingsPicker(isPresented: $isSharePresented, sharingItems: shareItems))
            }
#endif
        }
    }
}

#if os(iOS)
// Source: https://stackoverflow.com/a/58341956/135712
struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
}
#endif

#if os(macOS)
// Source: https://stackoverflow.com/a/60955909/135712
struct SharingsPicker: NSViewRepresentable {
    @Binding var isPresented: Bool
    var sharingItems: [Any] = []

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if isPresented {
            let picker = NSSharingServicePicker(items: sharingItems)
            picker.delegate = context.coordinator

            DispatchQueue.main.async {
                picker.show(relativeTo: .zero, of: nsView, preferredEdge: .minY)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(owner: self)
    }

    class Coordinator: NSObject, NSSharingServicePickerDelegate {
        let owner: SharingsPicker

        init(owner: SharingsPicker) {
            self.owner = owner
        }

        func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, didChoose service: NSSharingService?) {
            sharingServicePicker.delegate = nil
            self.owner.isPresented = false
        }

        func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, sharingServicesForItems items: [Any], proposedSharingServices proposedServices: [NSSharingService]) -> [NSSharingService] {
            guard let image = NSImage(systemSymbolName: "link", accessibilityDescription: nil),
                  let url = items.last as? URL else {
                return proposedServices
            }

            let copyService = NSSharingService(title: "Copy Link", image: image, alternateImage: nil) {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(url.absoluteString, forType: .string)
            }

            return [copyService] + proposedServices
        }
    }
}
#endif

struct TalkDetail_Previews: PreviewProvider {
    static let inMemory = PersistenceController(inMemory: true)
    static let talk: Talk = {
        let speaker1 = Member(context: inMemory.container.viewContext)
        speaker1.login = "1"
        speaker1.firstName = "John"
        speaker1.lastName = "Doe"
        speaker1.company = "MegaCorp"
        speaker1.photoURLString = "https://avatars.githubusercontent.com/u/886053?v=4"

        let speaker2 = Member(context: inMemory.container.viewContext)
        speaker2.login = "2"
        speaker2.firstName = "Jane"
        speaker2.lastName = ""
        speaker2.company = ""

        let talk = Talk(context: inMemory.container.viewContext)
        talk.identifier = "1"
        talk.speakersIdentifiers = speaker1.login! + Talk.serializationSeparator + speaker2.login!
        talk.title = "Au-delà des heures : La semaine de 4 jours comme levier d’égalité"
        talk.language = "fr"
        talk.format = "Talk"
        talk.room = "AMPHI2"
        talk.startDate = Date.now
        talk.endDate = Date(timeIntervalSinceNow: 3600)
        talk.summary =
			"""
			L’égalité…vaste sujet n’est ce pas ? 

			Égalité salariale, reconnaissance équitable, évolution dans l’entreprise… Il est temps de briser les barrières de genre ! Allons même plus loin sur la diversité et l’inclusion en offrant une flexibilité accrue aux employé.es ayant des responsabilités familiales, des engagements ou des besoins particuliers.

			Une révolution du travail se profile à l’horizon : la semaine de 4 jours. Un levier puissant pour l’égalité et je vais vous expliquer pourquoi.

			Au cours de cette conférence, nous explorerons en détail les mécanismes par lesquels la semaine de 4 jours contribue à la diminution des inégalités au travail. Des exemples concrets s’appuyant sur des témoignages et des études de cas mettront en lumière les bienfaits de cette approche. 

			Enfin, je vous donnerai les clés pour insuffler cette nouvelle façon de travailler dans votre propre structure. 
			Saisissez l’opportunité d’initier des transformations positives dès maintenant !
			"""
        return talk
    }()

    static var previews: some View {
        Group {
            TalkDetail(talk: talk)
        }
    }
}
