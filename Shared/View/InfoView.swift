//
//  InfoView.swift
//  mixit
//
//  Created by Vincent Tourraine on 05/08/2022.
//  Copyright © 2022 Studio AMANgA. All rights reserved.
//

import SwiftUI

struct InfoView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        List {
            Image("Logo")
            Text("May 24 & 25, 2022\nLyon, France")
        }
    }
}
