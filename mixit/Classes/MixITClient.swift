//
//  MixITClient.swift
//  mixit
//
//  Created by Vincent Tourraine on 22/11/15.
//  Copyright © 2015 Studio AMANgA. All rights reserved.
//

import UIKit

class MixITClient: AFHTTPSessionManager {

    convenience init() {
        let baseURL = NSURL(string: "http://www.mix-it.fr/api/")
        self.init(baseURL: baseURL)
    }
}
