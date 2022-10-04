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
    @State private var searchText = ""
    var searchQuery: Binding<String> {
      Binding {
        searchText
      } set: { newValue in
        searchText = newValue

        guard !newValue.isEmpty else {
          talks.nsPredicate = nil
          return
        }

        talks.nsPredicate = NSPredicate(format: "%K contains[cd] %@ OR %K contains[cd] %@", #keyPath(Talk.title), newValue, #keyPath(Talk.summary), newValue)
      }
    }

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
                            .swipeActions {
                                Button(talk.isFavorited ? "Remove from Favorites" : "Add to Favorites") {
                                    talk.toggleFavorited()
                                }
                                .tint(.mixitOrange)
                            }
                        }
                    }
                }
            }
            .searchable(text: searchQuery)
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
#if os(macOS)
                        InfoView()
                            .frame(minWidth: 400)
                            .navigationTitle("About MiXiT")
                            .toolbar {
                                ToolbarItem {
                                    Button("Close", action: {
                                        showingInfo = false
                                    })
                                }
                            }
#endif
#if os(iOS)
                        NavigationView {
                            InfoView()
                                .navigationTitle("About MiXiT")
                                .toolbar {
                                    ToolbarItem {
                                        Button("Close", action: {
                                            showingInfo = false
                                        })
                                    }
                                }
                        }
#endif
                    }
                }
            }
            Text("No Talk Selected")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}