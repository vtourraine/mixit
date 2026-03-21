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
    @EnvironmentObject var client: MixitClient

    let dateFormatter: DateIntervalFormatter = TalkRow.defaultDateFormatter()

    @State private var showingInfo = false
    @State private var searchText = ""
    static let yearPredicate = NSPredicate(format: "%K == %@", #keyPath(Talk.event), String(MixitClient.currentYear))
    var searchQuery: Binding<String> {
      Binding {
        searchText
      } set: { newValue in
        searchText = newValue

        guard !newValue.isEmpty else {
            talks.nsPredicate = ContentView.yearPredicate
          return
        }

        talks.nsPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSPredicate(format: "%K contains[cd] %@", #keyPath(Talk.title), newValue),
                NSPredicate(format: "%K contains[cd] %@", #keyPath(Talk.summary), newValue),
                NSPredicate(format: "%K contains[cd] %@", #keyPath(Talk.desc), newValue)
            ]),
            ContentView.yearPredicate])
      }
    }

    @SectionedFetchRequest<String, Talk>(
      sectionIdentifier: \.startDateString,
      sortDescriptors: [SortDescriptor(\.startDate, order: .forward)],
      predicate: yearPredicate
    ) var talks: SectionedFetchResults<String, Talk>

    var body: some View {
        NavigationView {
            List {
                ForEach(talks) { section in
                    Section(header: Text(section.id)) {
                        ForEach(section) { talk in
                            NavigationLink {
                                TalkDetail(talk: talk)
                            } label: {
                                TalkRow(dateFormatter: dateFormatter, talk: talk)
                            }
                            .swipeActions {
                                Button {
                                    talk.toggleFavorited()
                                } label: {
                                    if talk.isFavorited {
                                        Label("Remove from Favorites", systemImage: "star.slash.fill")
                                    }
                                    else {
                                        Label("Add to Favorites", systemImage: "star.fill")
                                    }
                                }
                                .tint(.miXiTOrange)
                            }
                        }
                    }
                }
            }
            .refreshable {
                client.fetchTalks()
                client.fetchUsers()
            }
            .searchable(text: searchQuery)
#if os(iOS)
            .listStyle(.plain)
#endif
            .navigationTitle("MiXiT Schedule")
            .overlay {
                if #available(iOS 17, macOS 14, *) {
                    if talks.isEmpty && !searchText.isEmpty {
                        ContentUnavailableView.search
                    }
                }
            }
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
                                    if #available(iOS 26, macOS 26, *) {
                                        Button(role: .close) {
                                            showingInfo = false
                                        }
                                    } else {
                                        Button("Close") {
                                            showingInfo = false
                                        }
                                    }
                                }
                            }
#endif
#if os(iOS)
                        NavigationView {
                            InfoView()
                                .navigationTitle("About")
                                .toolbar {
                                    ToolbarItem {
                                        if #available(iOS 26, macOS 26, *) {
                                            Button(role: .close) {
                                                showingInfo = false
                                            }
                                        } else {
                                            Button("Close") {
                                                showingInfo = false
                                            }
                                        }
                                    }
                                }
                        }
#endif
                    }
                }
            }
            if #available(iOS 17.0, macOS 14.0, *) {
                ContentUnavailableView {
                    Text("No Talk Selected")
                }
            } else {
                Text("No Talk Selected")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
