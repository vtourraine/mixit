//
//  UserResource.swift
//  mixit
//
//  Created by Vincent Tourraine on 05/08/2022.
//  Copyright © 2022 Studio AMANgA. All rights reserved.
//

import Foundation
import CoreData

struct UserResponse: Codable {
    let company: String?
    let firstname: String?
    let lastname: String?
    let login: String
    let photoUrl: String?
}

extension NSManagedObjectContext {
    func fetchMember(with login: String) throws -> Member? {
        let fetchRequest : NSFetchRequest<Member> = Member.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(Member.login), login)
        let fetchedResults = try fetch(fetchRequest)
        return fetchedResults.first
    }

    func update(with userResponses: [UserResponse]) {
        for userResponse in userResponses {
            if let existingMember = try? fetchMember(with: userResponse.login) {
                existingMember.update(with: userResponse)
            }
            else {
                let newMember = Member(context: self)
                newMember.login = userResponse.login
                newMember.update(with: userResponse)
            }
        }
    }
}
