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
            VStack {
                Text(talk.title ?? "")
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                ForEach(talk.fetchSpeakers()) { speaker in
                    HStack {
                        if let photoURL = speaker.photoURLString {
                            AsyncImage(url: URL(string: photoURL)) { image in
                                image.resizable()
                                    .clipShape(Circle())
                            } placeholder: {
                                Image(systemName: "person.crop.circle")
                                    .font(.system(size: 32))
                            }
                            .frame(width: 40, height: 40)
                        }
                        else {
                            Image(systemName: "person.crop.circle")
                                .font(.system(size: 32))
                                .frame(width: 40, height: 40)
                        }
                        VStack(alignment: .leading) {
                            Text(nameFormatter.string(from: PersonNameComponents(givenName: speaker.firstName, familyName: speaker.lastName)))
                                .font(.body)
                            if let company = speaker.company {
                                Text(company)
                                    .font(.body).italic()
                            }
                        }
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer(minLength: 20)

                if let emoji = talk.emojiForLanguage, let format = talk.format {
                    Text("\(emoji) \(format.localizedCapitalized)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer(minLength: 6)
                }
				if let room = talk.room {
					let formattedRoom = NSLocalizedString(room, tableName: "Rooms", comment: "")
					TalkDetailItem(text: formattedRoom, systemImageName: "mappin.and.ellipse")
				}
                if let startDate = talk.startDate, let endDate = talk.endDate {
                    TalkDetailItem(text: "\(Talk.dayFormatter.string(from: startDate).localizedCapitalized), \(timeIntervalFormatter.string(from: startDate, to: endDate))", systemImageName: "clock")
                }
                else {
                    TalkDetailItem(text: "Not announced yet", systemImageName: "clock")
                }

                Spacer(minLength: 20)

                if let summary = talk.summary {
                    Text(summary)
                        .font(.body).italic()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer(minLength: 20)
                }

                if let desc = talk.desc {
                    Text(desc)
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
        talk.title = "First Talk"
        talk.language = "fr"
        talk.format = "Keynote"
        talk.room = "AMPHI2"
        talk.startDate = Date()
        talk.endDate = Date().addingTimeInterval(3600)
        talk.desc = "Bla bla bla... Bla bla bla... Bla bla bla..."
        return talk
    }()

    static var previews: some View {
        Group {
            TalkDetail(talk: talk)
        }
    }
}
