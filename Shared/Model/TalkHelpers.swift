//
//  TalkHelpers.swift
//  mixit
//
//  Created by Tourraine, Vincent (ELS-HBE) on 04/08/2022.
//  Copyright © 2022 Studio AMANgA. All rights reserved.
//

import Foundation

extension Talk {

    static let serializationSeparator = ";"

    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()

    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    @objc var startDateString: String {
        if let startDate = startDate {
            let timeString = Talk.timeFormatter.string(from: startDate)
            let dateString = Talk.dayFormatter.string(from: startDate).localizedCapitalized
            return "\(dateString), \(timeString)"
        }
        else {
            return NSLocalizedString("Undefined", comment: "")
        }
    }

    func update(with talkResponse: TalkResponse) {
        desc = talkResponse.description
        format = talkResponse.format
        language = talkResponse.language
        room = talkResponse.room
        summary = talkResponse.summary
        title = talkResponse.title
        startDate = talkResponse.start
        endDate = talkResponse.end
        if let event = Int(talkResponse.event) {
            year = NSNumber(value: event)
        }
        else {
            year = nil
        }
        speakersIdentifiers = talkResponse.speakerIds.joined(separator: Talk.serializationSeparator)
    }

    var emojiForLanguage: String? {
        get {
            guard let language = language else {
                return nil
            }

            if language == "fr" || language == "FRENCH" {
                return "🇫🇷"
            }
            else if language == "en" || language == "ENGLISH" {
                return "🇺🇸"
            }

            return nil
        }
    }

    func fetchSpeakers() -> [Member] {
        guard let speakersIdentifiers = speakersIdentifiers else {
            return []
        }

        let speakersIdentifiersArray = speakersIdentifiers.components(separatedBy: Talk.serializationSeparator)
        let speakers = speakersIdentifiersArray.compactMap { identifier in
            return try? managedObjectContext?.fetchMember(with: identifier)
        }

        return speakers
    }

    func toggleFavorited() {
        if let favorited = favorited {
            self.favorited = NSNumber(booleanLiteral: !favorited.boolValue)
        }
    }
}
