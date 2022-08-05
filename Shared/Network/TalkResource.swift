//
//  TalkResource.swift
//  mixit
//
//  Created by Tourraine, Vincent (ELS-HBE) on 05/08/2022.
//  Copyright © 2022 Studio AMANgA. All rights reserved.
//

import Foundation
import CoreData

struct TalkResponse: Codable {
    let format: String
    let event: String
    let title: String
    let summary: String
    let speakerIds: [String]
    let language: String
    let addedAt: Date
    let description: String
    let topic: String
    let video: String?
    let room: String
    let start: Date
    let end: Date
    // let photoUrls
    let slug: String
    let id: String
}

extension NSManagedObjectContext {
    func fetchTalk(with id: String) throws -> Talk? {
        let fetchRequest : NSFetchRequest<Talk> = Talk.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(Talk.identifier), id)
        let fetchedResults = try fetch(fetchRequest)
        return fetchedResults.first
    }

    func update(with talkResponses: [TalkResponse]) {
        for talkResponse in talkResponses {
            if let existingTalk = try? fetchTalk(with: talkResponse.id) {
                existingTalk.update(with: talkResponse)
            }
            else {
                let newTalk = Talk(context: self)
                newTalk.identifier = talkResponse.id
                newTalk.update(with: talkResponse)
            }
        }
    }
}
