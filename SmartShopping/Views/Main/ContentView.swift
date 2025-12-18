//
//  ContentView.swift
//  SmartShopping
//
//  Created by user279038 on 12/1/25.
//


import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var listsViewModel: ListsViewModel
    @EnvironmentObject var templatesViewModel: TemplatesViewModel

    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
                .environmentObject(listsViewModel) // ADD THIS
                .environmentObject(templatesViewModel) // ADD THIS

            // Lists Tab
            ListsView()
                .tabItem {
                    Label("Lists", systemImage: "list.bullet")
                }
                .tag(1)
                .environmentObject(listsViewModel) // ADD THIS

            // Templates Tab
            TemplatesView()
                .tabItem {
                    Label("Templates", systemImage: "square.grid.2x2")
                }
                .tag(2)
                .environmentObject(templatesViewModel) // ADD THIS
                .environmentObject(listsViewModel) // ADD THIS (needed for creating lists from templates)

            // Analytics Tab
            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar")
                }
                .tag(3)
                .environmentObject(listsViewModel) // ADD THIS
                .environmentObject(templatesViewModel) // ADD THIS

            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(4)
                .environmentObject(authViewModel) // ADD THIS
        }
        .accentColor(.blue)
        // Also pass environment objects at the TabView level
        .environmentObject(authViewModel)
        .environmentObject(listsViewModel)
        .environmentObject(templatesViewModel)
        .task {
            // Load lists ONCE
            await listsViewModel.fetchLists()
            await templatesViewModel.fetchTemplates()
        }
    }
}
