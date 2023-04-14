//
//  TalkDetailItem.swift
//  mixit
//
//  Created by Vincent Tourraine on 14/04/2023.
//  Copyright © 2023 Studio AMANgA. All rights reserved.
//

import SwiftUI

struct TalkDetailItem: View {
    var text: String
    var systemImageName: String

    var body: some View {
        HStack {
            Image(systemName: systemImageName)
            Text(text)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        Spacer(minLength: 6)
    }
}

struct TalkDetailItem_Previews: PreviewProvider {
    static var previews: some View {
        TalkDetailItem(text: "Music", systemImageName: "opticaldisc")
    }
}
