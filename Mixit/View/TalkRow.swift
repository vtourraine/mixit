//
//  TalkRaw.swift
//  mixit
//
//  Created by Vincent Tourraine on 04/08/2022.
//  Copyright © 2022 Studio AMANgA. All rights reserved.
//

import SwiftUI

struct TalkRow: View {
    @ObservedObject var talk: Talk

    // When next year schedule isn’t available yet, we keep all talks “active”
    let isInMaintenanceModeInBetweenEditions = false

    var subtitle: String {
        get {
            var text = ""

            if let startDate = talk.startDate, let endDate = talk.endDate {
                let formatter = DateIntervalFormatter()
                formatter.dateStyle = .none
                formatter.timeStyle = .short
                let dateString = formatter.string(from: startDate, to: endDate)
                text += " • " + dateString
            }

            if let room = talk.room {
                let formattedRoom = NSLocalizedString(room, tableName: "Rooms", comment: "")
                text += " • " + formattedRoom
            }

            return text
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Spacer(minLength: 2)
                Text(talk.title ?? "")
                    .font(.body.bold())

                HStack(spacing: 0) {
                    if let format = talk.format {
                        Text(format.localizedCapitalized)
                            .bold()
                    }

                    Text(subtitle)
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                Spacer(minLength: 2)
            }
            Spacer()
            if talk.favorited?.boolValue ?? false {
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
        talk.startDate = Date()
        talk.endDate = Date().addingTimeInterval(3600)
        return talk
    }()

    static var previews: some View {
        Group {
            TalkRow(talk: talk)
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
