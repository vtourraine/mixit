//
//  ContentView.swift
//  Shared
//
//  Created by Vincent Tourraine on 04/08/2022.
//  Copyright © 2022 Studio AMANgA. All rights reserved.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var showingInfo = false

    @SectionedFetchRequest<String, Talk>(
      // entity: Talk.entity(),
      sectionIdentifier: \.startDateString,
      sortDescriptors: [SortDescriptor(\.startDate, order: .forward)]
    ) var talks: SectionedFetchResults<String, Talk>
    private var dateFormatter = DateFormatter()

    var body: some View {
        NavigationView {
            List {
                ForEach(talks) { section in
                    Section(header: Text(section.id)) {
                        ForEach(section) { talk in
                            NavigationLink {
                                TalkDetail(talk: talk)
                            } label: {
                                TalkRow(talk: talk)
                            }
                        }
                    }
                }
            }
#if os(iOS)
            .listStyle(.plain)
#endif
            .navigationTitle("MiXiT Schedule")
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        showingInfo.toggle()
                    }, label: {
                        Label("Info", systemImage: "info.circle")
                    })
                    .sheet(isPresented: $showingInfo) {
                        NavigationView {
                            VStack {
                                InfoView()
                            }
                            .navigationTitle("About MiXiT")
                            .toolbar {
                                ToolbarItem {
                                    Button("Close", action: {
                                        showingInfo = false
                                    })
                                }
                            }
                        }
                    }
                }
            }
            Text("No Talk Selected")
        }
    }

    private func addItem() {
        /*
        withAnimation {
            let newItem = Talk(context: viewContext)
            // newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
         */
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
