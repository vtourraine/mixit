//
//  MemberHelpers.swift
//  mixit
//
//  Created by Vincent Tourraine on 05/08/2022.
//  Copyright © 2022 Studio AMANgA. All rights reserved.
//

import Foundation

extension Member {

    func update(with userResponse: UserResponse) {
        company = userResponse.company
        firstName = userResponse.firstname
        lastName = userResponse.lastname

        if let photoURL = userResponse.photoUrl, photoURL.hasPrefix("/images") {
            photoURLString = "https://mixitconf.org" + photoURL
        }
        else {
            photoURLString = userResponse.photoUrl
        }
    }
}
