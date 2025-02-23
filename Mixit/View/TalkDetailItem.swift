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
                .font(.title2)
                .foregroundStyle(Color.miXiTOrange)
                //.padding(.horizontal, 6)
            Text(text)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TalkDetailItem_Previews: PreviewProvider {
    static var previews: some View {
        TalkDetailItem(text: "Lovelace Amphitheater", systemImageName: "mappin")
            .frame(maxWidth: 150)
    }
}
