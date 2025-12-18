//
//  HomeView.swift
//  SmartShopping
//
//  Created by user279038 on 12/1/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var listsViewModel: ListsViewModel
    @EnvironmentObject var templatesViewModel: TemplatesViewModel
    @State private var showingCreateList = false
    @State private var showingCreateTemplate = false
    @State private var showingProfile = false
    @State private var refreshID = UUID()
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    // Welcome Header
                    welcomeHeader
                    
                    // Quick Stats
                    statsSection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Recent Lists
                    recentListsSection
                    
                    Spacer(minLength: 50)
                }
                .padding(.vertical)
            }
            .navigationTitle("Smart Shopping")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingProfile = true }) {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingCreateList = true }) {
                            Label("New List", systemImage: "list.bullet")
                        }
                        
                        Button(action: { showingCreateTemplate = true }) {
                            Label("New Template", systemImage: "square.grid.2x2")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingCreateList) {
                CreateListView()
                    .environmentObject(listsViewModel)
            }
            .sheet(isPresented: $showingCreateTemplate) {
                CreateTemplateView(onTemplateCreated: {
                    // Refresh templates using the view model
                    Task {
                        await templatesViewModel.fetchTemplates()
                    }
                })
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView()
                    .environmentObject(authViewModel)
            }
            .refreshable {
                await refreshData()
            }
            .onAppear {
                // Load data when view appears
                loadInitialData()
            }
            // Add loading state overlay
            .overlay {
                if listsViewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func refreshData() async {
        // Refresh both lists and templates
        await listsViewModel.fetchLists()
        await templatesViewModel.fetchTemplates()
    }

    private func loadInitialData() {
        // Only fetch if we don't have data yet
        if listsViewModel.lists.isEmpty {
            Task {
                await listsViewModel.fetchLists()
            }
        }
        
        if templatesViewModel.templates.isEmpty {
            Task {
                await templatesViewModel.fetchTemplates()
            }
        }
    }
    
    
    // MARK: - Computed Properties
    
    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome back!")
                .font(.title3)
                .foregroundColor(.gray)
            
            HStack {
                Text(authViewModel.currentUserEmail.components(separatedBy: "@").first ?? "User")
                    .font(.title)
                    .fontWeight(.bold)
                    .lineLimit(1)
                
                Spacer()
                
                Image(systemName: "cart.fill")
                    .font(.title)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
    }
    
    private var statsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                let activeLists = listsViewModel.lists.filter { !$0.isCompleted }.count
                
                let totalItems = listsViewModel.lists.reduce(0) { total, list in
                    total + list.items.count
                }
                
                let completedLists = listsViewModel.lists.filter { $0.isCompleted }.count
                let totalSpent = listsViewModel.lists.reduce(0) { $0 + $1.totalSpent }
                
                // Add templates count
                let templateCount = templatesViewModel.templates.count
                
                StatCard(
                    title: "Active Lists",
                    value: "\(activeLists)",
                    icon: "list.bullet",
                    color: .blue
                )
                
                StatCard(
                    title: "Total Items",
                    value: "\(totalItems)",
                    icon: "cart",
                    color: .green
                )
                
                StatCard(
                    title: "Templates",
                    value: "\(templateCount)",
                    icon: "square.grid.2x2",
                    color: .orange
                )
                
                StatCard(
                    title: "Total Spent",
                    value: String(format: "$%.0f", totalSpent),
                    icon: "dollarsign.circle",
                    color: .purple
                )
            }
            .padding(.horizontal)
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Quick Actions")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                QuickActionButton(
                    title: "New List",
                    icon: "plus.circle.fill",
                    color: .blue,
                    action: { showingCreateList = true }
                )
                
                QuickActionButton(
                    title: "Templates",
                    icon: "square.grid.2x2",
                    color: .orange,
                    action: {
                        showingCreateTemplate = true
                    }
                )
                
                QuickActionButton(
                    title: "Scan Item (Not Supported Yet)",
                    icon: "barcode.viewfinder",
                    color: .green,
                    action: { }
                )
                
                NavigationLink(destination: AnalyticsView()) {
                                VStack(spacing: 10) {
                                    Image(systemName: "chart.bar.fill")
                                        .font(.title2)
                                        .foregroundColor(.purple)
                                    
                                    Text("Analytics")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal)
                    }
                }
                
                
    private var recentListsSection: some View {
        Group {
            if !listsViewModel.lists.isEmpty {
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("Recent Lists")
                            .font(.headline)
                        
                        Spacer()
                        
                        NavigationLink("See All") {
                            ListsView()
                                .environmentObject(listsViewModel)
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                    
                    ForEach(listsViewModel.lists.prefix(3)) { list in
                        NavigationLink(destination: ListDetailView(list: list)) {
                            ListCard(list: list)
                                .padding(.horizontal)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            } else {
                emptyStateView
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.bullet")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .padding(.top, 20)
            
            Text("No lists yet")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Create your first shopping list to get started")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: { showingCreateList = true }) {
                Text("Create List")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 150, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}


struct ListCard: View {
    let list: ShoppingList
    @EnvironmentObject var listsViewModel: ListsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(list.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Spacer()
                
                if list.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
            
            if let description = list.description, !description.isEmpty {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            ProgressView(value: list.progress)
                .progressViewStyle(LinearProgressViewStyle())
                .tint(list.progress == 1 ? .green : .blue)
                .animation(.easeInOut, value: list.progress) // Add animation
            
            HStack {
                let purchasedCount = list.items.filter { $0.isPurchased }.count
                Text("\(purchasedCount)/\(list.items.count) items")
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(list.formattedBudget)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 2, x: 0, y: 1)
        // Listen for changes in the ViewModel
        .onReceive(listsViewModel.$lists) { _ in
            // This forces a refresh when lists change
        }
    }
}
