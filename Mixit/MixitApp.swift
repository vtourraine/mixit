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
    @Environment(\.scenePhase) var scenePhase

    let persistenceController = PersistenceController.shared
    let client = MixitClient()

    func sync() {
        client.context = persistenceController.container.viewContext
        client.fetchTalks()
        client.fetchUsers()
    }

    func save() {
        let context = persistenceController.container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Cannot save context: \(error.localizedDescription)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(client)
                .onAppear() {
                    sync()
                }
                .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { _ in
                    // source: https://stackoverflow.com/a/75532645
                    save()
                }
        }
        .onChange(of: scenePhase) { _ in
            save()
        }
    }
}
