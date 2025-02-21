//
//  TalkDetail.swift
//  mixit
//
//  Created by Vincent Tourraine on 04/08/2022.
//  Copyright © 2022 Studio AMANgA. All rights reserved.
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

    @Environment(\.colorScheme) private var colorScheme

    var shareItems: [Any] {
        get {
            if let title = talk.title, let year = talk.year,
               let url = URL(string: "https://mixitconf.org/fr/\(year)") {
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
                Text(talk.title ?? "")
                    .font(.largeTitle).fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 10)

                if
                    let language = talk.localizedLanguage,
                    let format = talk.format
                {

                    HStack(spacing: 0) {
                        Text(format.localizedCapitalized)
                        Text(" • ")
                        Text(language)
                    }
                    .foregroundStyle(.secondary)
                    .font(.subheadline)

                    Spacer(minLength: 20)
                }

                HStack {
                    if let startDate = talk.startDate, let endDate = talk.endDate {
                        TalkDetailItem(text: "\(Talk.dayFormatter.string(from: startDate).localizedCapitalized)\n\(timeIntervalFormatter.string(from: startDate, to: endDate))", systemImageName: "clock.circle.fill", imageColor: .blue)
                    }
                    if let room = talk.room {
                        let formattedRoom = NSLocalizedString(room, tableName: "Rooms", comment: "")
                        TalkDetailItem(text: formattedRoom, systemImageName: "mappin.circle.fill", imageColor: .red)
                    }
                    else {
                        TalkDetailItem(text: "Not announced yet", systemImageName: "ellipsis.circle.fill", imageColor: .gray)
                    }
                }

                Spacer(minLength: 20)

                ForEach(talk.fetchSpeakers()) { speaker in
                    HStack(alignment: .top) {
                        // Speaker photo
                        if let photoURL = speaker.photoURLString {
                            AsyncImage(url: URL(string: photoURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .clipShape(Circle())
                                    .overlay {
                                        Circle()
                                            .strokeBorder(
                                                .primary.opacity(
                                                    colorScheme == .light
                                                    ? 0.1
                                                    : 0.3
                                                ),
                                                lineWidth: 1
                                            )
                                    }
                            } placeholder: {
                                Image(systemName: "person.crop.circle")
                                    .resizable()
                                    .font(.system(size: 10))
                            }
                            .frame(width: 38, height: 38)
                        }
                        else {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .font(.system(size: 10))
                                .frame(width: 38, height: 38)
                        }

                        // Speaker info
                        VStack(alignment: .leading) {
                            Text(nameFormatter.string(from: PersonNameComponents(givenName: speaker.firstName, familyName: speaker.lastName)))
                                .font(.subheadline.weight(.semibold))

                            if let company = speaker.company {
                                Text(company)
                                    .font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                        .frame(minHeight: 38)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer(minLength: 20)
                }

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
                Button(action: {
                    showAddEventModal.toggle()
                }) {
                    Label("Add to Calendar", systemImage: "calendar.badge.plus")
                }
                Button(action: {
                    talk.toggleFavorited()
                }) {
                    Label(talk.isFavorited ? "Remove from Favorites" : "Add to Favorites", systemImage: talk.isFavorited ? "star.fill" : "star")
                }
                Button(action: {
                    self.isSharePresented = true
                }) {
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
                Button(action: {
                    talk.toggleFavorited()
                }) {
                    Label("Add to Favorites", systemImage: (talk.favorited?.boolValue ?? false) ? "star.fill" : "star")
                }
            }
            ToolbarItem {
                Button(action: {
                    self.isSharePresented = true
                }) {
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
    }
}
#endif

struct TalkDetail_Previews: PreviewProvider {
    static let inMemory = PersistenceController(inMemory: true)
    static let talk: Talk = {
        let talk = Talk(context: inMemory.container.viewContext)
        talk.identifier = "1"
        talk.title = "Au-delà des heures : La semaine de 4 jours comme levier d’égalité"
        talk.language = "fr"
        talk.format = "Talk"
        talk.room = "AMPHI2"
        talk.startDate = Date()
        talk.endDate = Date().addingTimeInterval(3600)
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
