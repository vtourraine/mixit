//
//  SpeakerView.swift
//  Mixit
//
//  Created by Vincent Tourraine on 22/02/2025.
//  Copyright © 2025 Studio AMANgA. All rights reserved.
//

import SwiftUI

struct SpeakerView: View {
    let nameFormatter: PersonNameComponentsFormatter

    @ObservedObject var speaker: Member

    var body: some View {
        HStack(alignment: .top) {
            // Speaker photo
            if let photoURL = speaker.photoURLString {
                AsyncImage(url: URL(string: photoURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                }
                .frame(width: 38, height: 38)
            }
            else {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .frame(width: 38, height: 38)
            }

            // Speaker info
            VStack(alignment: .leading) {
                Text(nameFormatter.string(from: PersonNameComponents(givenName: speaker.firstName, familyName: speaker.lastName)))
                    .font(.subheadline)

                if let company = speaker.company {
                    Text(company)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(minHeight: 38)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SpeakerView_Previews: PreviewProvider {
    static let inMemory = PersistenceController(inMemory: true)
    static let speaker: Member = {
        let speaker = Member(context: inMemory.container.viewContext)
        speaker.login = "1"
        speaker.firstName = "John"
        speaker.lastName = "Doe"
        speaker.company = "MegaCorp"
        speaker.photoURLString = "https://avatars.githubusercontent.com/u/886053?v=4"
        return speaker
    }()

    static var previews: some View {
        Group {
            SpeakerView(nameFormatter: PersonNameComponentsFormatter(), speaker: speaker)
        }
    }
}
