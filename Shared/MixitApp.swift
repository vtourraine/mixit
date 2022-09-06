//
//  MixitApp.swift
//  Shared
//
//  Created by Vincent Tourraine on 04/08/2022.
//  Copyright © 2022 Studio AMANgA. All rights reserved.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

@main
struct MixitApp: App {
    let persistenceController = PersistenceController.shared
    let client = MixitClient()

#if os(iOS)
    init() {
        updateNavigationBarColor()
    }
#endif

    func sync() {
        client.context = persistenceController.container.viewContext
        client.fetchTalks()
        client.fetchUsers()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear() {
                    sync()
                }
        }
    }

#if os(iOS)
    func updateNavigationBarColor() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "Purple")!]
        var largeTitleTextAttributes = appearance.largeTitleTextAttributes
        largeTitleTextAttributes[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: 34)
        largeTitleTextAttributes[NSAttributedString.Key.foregroundColor] = UIColor(named: "Purple")
        appearance.largeTitleTextAttributes = largeTitleTextAttributes
        // appearance.backgroundColor = UIColor(named: "Purple")

        UINavigationBar.appearance().tintColor = UIColor(named: "Orange")
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().barStyle = .black
    }
#endif
}
