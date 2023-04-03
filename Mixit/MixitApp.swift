//
//  MixitApp.swift
//  Shared
//
//  Created by Vincent Tourraine on 04/08/2022.
//  Copyright © 2022 Studio AMANgA. All rights reserved.
//

import SwiftUI

@main
struct MixitApp: App {
    let persistenceController = PersistenceController.shared
    let client = MixitClient()

    func sync() {
        client.context = persistenceController.container.viewContext
        client.fetchTalks()
        // client.fetchUsers()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(client)
                .onAppear() {
                    sync()
                }
        }
    }
}
