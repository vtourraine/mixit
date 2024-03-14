//
//  AddEvent.swift
//  Mixit
//
//  Created by Tourraine, Vincent (ELS-HBE) on 14/03/2024.
//  Copyright © 2024 Studio AMANgA. All rights reserved.
//

#if os(iOS)

import SwiftUI

// Based on: https://github.com/bvechiato/new-event-app

struct AddEvent: UIViewControllerRepresentable {
    let talk: Talk
    
    func makeUIViewController(context: Context) -> AddEventController {
        let viewController = AddEventController()
        viewController.talk = talk
        return viewController
    }

    func updateUIViewController(_ uiViewController: AddEventController, context: Context) {
        // We need this to follow the protocol, but don't have to implement it
        // Edit here to update the state of the view controller with information from SwiftUI
    }
}

#endif
