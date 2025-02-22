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
    var imageColor: Color

    var body: some View {
        HStack {
            Image(systemName: systemImageName)
                .font(.title2)
                .foregroundStyle(imageColor)
                .padding(.horizontal, 6)
            Text(text)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        Spacer(minLength: 6)
    }
}

struct TalkDetailItem_Previews: PreviewProvider {
    static var previews: some View {
        TalkDetailItem(text: "Lovelace Amphitheater", systemImageName: "mappin.circle.fill", imageColor: .red)
            .frame(maxWidth: 150)
    }
}
