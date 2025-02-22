//
//  TalkHelpers.swift
//  mixit
//
//  Created by Vincent Tourraine on 04/08/2022.
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
        if let startDate {
            let timeString = Talk.timeFormatter.string(from: startDate)
            let dateString = Talk.dayFormatter.string(from: startDate).localizedCapitalized
            return "\(dateString), \(timeString)"
        }
        else {
            return NSLocalizedString("Undefined", comment: "")
        }
    }

    /// The description if available, or the summary otherwise.
    var effectiveDescription: String? {
        guard let desc, desc != "" else {
            return summary
        }

        return desc
    }

    /// The summary if the description is available, otherwise nothing.
    var effectiveSummary: String? {
        guard let desc, desc != "" else {
            return nil
        }

        return summary
    }

    @objc
    var shortestAvailableDescription: String? {
        effectiveSummary ?? effectiveDescription
    }

    func update(with talkResponse: TalkResponse) {
        desc = talkResponse.description.cleaned()
        format = talkResponse.format.replacingOccurrences(of: "_", with: " ")
        language = talkResponse.language
        room = talkResponse.room
        summary = talkResponse.summary.cleaned()
        title = talkResponse.title.cleaned()
        startDate = talkResponse.start
        endDate = talkResponse.end
        event = talkResponse.event
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
            guard let language else {
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

    var localizedLanguage: String? {
        get {
            guard let language else {
                return nil
            }

            if language == "fr" || language == "FRENCH" {
                return NSLocalizedString("French", comment: "")
            }
            else if language == "en" || language == "ENGLISH" {
                return NSLocalizedString("English", comment: "")
            }

            return nil
        }
    }

    func fetchSpeakers() -> [Member] {
        guard let speakersIdentifiers else {
            return []
        }

        let speakersIdentifiersArray = speakersIdentifiers.components(separatedBy: Talk.serializationSeparator)
        let speakers = speakersIdentifiersArray.compactMap { identifier in
            return try? managedObjectContext?.fetchMember(with: identifier)
        }

        return speakers
    }

    func toggleFavorited() {
        if let favorited {
            self.favorited = NSNumber(booleanLiteral: !favorited.boolValue)
        }
    }

    var isFavorited: Bool {
        get {
            return favorited?.boolValue ?? false
        }

        set {
            favorited = NSNumber(booleanLiteral: newValue)
        }
    }

    var isUpcomingTalk: Bool {
        guard let endDate else {
            return false
        }

        // DEBUG:
        // let date = Date(timeIntervalSince1970: 1681400976)
        // return endDate.timeIntervalSince(date) > 0
        return endDate.timeIntervalSinceNow > 0
    }
}

extension String {
    func cleaned() -> String {
        return
            replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&#34;", with: "\"")
            .replacingOccurrences(of: "&amp;", with: "&")
    }
}
