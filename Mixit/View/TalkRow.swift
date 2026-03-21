//
//  TalkRaw.swift
//  mixit
//
//  Created by Vincent Tourraine on 04/08/2022.
//  Copyright © 2022 Studio AMANgA. All rights reserved.
//

import SwiftUI

struct TalkRow: View {
    let dateFormatter: DateIntervalFormatter

    static func defaultDateFormatter() -> DateIntervalFormatter {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }

    @ObservedObject var talk: Talk

    // When next year schedule isn’t available yet, we keep all talks “active”
    let isInMaintenanceModeInBetweenEditions = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Spacer(minLength: 2)
                if let title = talk.title {
                    Text(title)
                        .font(.headline)
                        .lineLimit(3) // explicit value necessary for macOS
                }

                HStack {
                    if let format = talk.format {
                        Text(format.localizedCapitalized)
                            .bold()
                            .foregroundStyle(.miXiTOrange)
                    }

                    if let room = talk.room {
                        let formattedRoom = NSLocalizedString(room, tableName: "Rooms", comment: "")
                        Text(formattedRoom)
                    }
                }
                .font(.caption)

                Spacer(minLength: 2)
            }
            Spacer()
            if talk.isFavorited {
                Image(systemName: "star.fill")
                    .foregroundColor(.orange)
            }
        }
        .opacity((isInMaintenanceModeInBetweenEditions || talk.isUpcomingTalk) ? 1 : 0.5)
    }
}

struct TalkRow_Previews: PreviewProvider {
    static let inMemory = PersistenceController(inMemory: true)
    static let talk: Talk = {
        let talk = Talk(context: inMemory.container.viewContext)
        talk.identifier = "1"
        talk.title = "First Talk"
        talk.language = "fr"
        talk.format = "Keynote"
        talk.room = "AMPHI2"
        talk.startDate = Date.now
        talk.endDate = Date(timeIntervalSinceNow: 3600)
        return talk
    }()
    static let talkFav: Talk = {
        let talk = Talk(context: inMemory.container.viewContext)
        talk.identifier = "2"
        talk.title = "Second Talk"
        talk.language = "en"
        talk.format = "Keynote"
        talk.room = "AMPHI2"
        talk.startDate = Date.now
        talk.endDate = Date(timeIntervalSinceNow: 3600)
        talk.isFavorited = true
        return talk
    }()

    static var previews: some View {
        Group {
            List {
                TalkRow(dateFormatter: TalkRow.defaultDateFormatter(), talk: talk)
                TalkRow(dateFormatter: TalkRow.defaultDateFormatter(), talk: talkFav)
            }
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
