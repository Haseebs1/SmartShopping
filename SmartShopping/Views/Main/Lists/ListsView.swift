//
//  ListsView.swift
//  SmartShopping
//
//  Created by user279038 on 12/1/25.
//

import SwiftUI

struct ListsView: View {
    @EnvironmentObject var listsViewModel: ListsViewModel
    @State private var showingCreateList = false
    @State private var searchText = ""
    @State private var selectedFilter: ListFilter = .all
    @State private var sortOrder: SortOrder = .dateDesc
    
    enum ListFilter: String, CaseIterable {
        case all = "All"
        case active = "Active"
        case completed = "Completed"
        
        var icon: String {
            switch self {
            case .all: return "list.bullet"
            case .active: return "clock"
            case .completed: return "checkmark.circle"
            }
        }
    }
    
    enum SortOrder: String, CaseIterable {
        case dateDesc = "Newest First"
        case dateAsc = "Oldest First"
        case nameAsc = "Name A-Z"
        case nameDesc = "Name Z-A"
    }
    
    var filteredLists: [ShoppingList] {
        var filtered = listsViewModel.lists
        
        // Apply filter
        switch selectedFilter {
        case .active:
            filtered = filtered.filter { !$0.isCompleted }
        case .completed:
            filtered = filtered.filter { $0.isCompleted }
        case .all:
            break
        }
        
        // Apply search
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply sorting
        switch sortOrder {
        case .dateDesc:
            filtered.sort { $0.createdAt > $1.createdAt }
        case .dateAsc:
            filtered.sort { $0.createdAt < $1.createdAt }
        case .nameAsc:
            filtered.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .nameDesc:
            filtered.sort { $0.name.localizedCompare($1.name) == .orderedDescending }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationView {
            contentView
                .navigationTitle("Shopping Lists")
                .searchable(text: $searchText, prompt: "Search lists")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingCreateList = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        filterMenu
                    }
                }
                .sheet(isPresented: $showingCreateList) {
                    NavigationView {
                        CreateListView()
                    }
                }
                .task {
                    if listsViewModel.lists.isEmpty {
                        await listsViewModel.fetchLists()
                    }
                }
                .refreshable {
                    await listsViewModel.refresh()
                }
        }
    }
    
    // MARK: - Content Views
    private var contentView: some View {
        Group {
            if listsViewModel.isLoading {
                ProgressView("Loading lists...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if filteredLists.isEmpty {
                emptyStateView
            } else {
                listContentView
            }
        }
    }
    
    private var listContentView: some View {
        List {
            ForEach(filteredLists) { list in
                NavigationLink(destination: ListDetailView(list: list)) {
                    listRow(for: list)
                }
                .swipeActions(edge: .trailing) {
                    swipeActions(for: list)
                }
            }
        }
        .listStyle(.plain)
    }
    
    private func listRow(for list: ShoppingList) -> some View {
        HStack(spacing: 12) {
            // Status indicator
            Circle()
                .fill(list.isCompleted ? Color.green : Color.blue)
                .frame(width: 10, height: 10)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(list.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if list.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
                
                HStack(spacing: 12) {
                    Text("\(list.items.count) items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let budget = list.budget {
                        Text("Budget: \(budget, format: .currency(code: "USD"))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Progress bar
                if !list.items.isEmpty {
                    ProgressView(value: list.progress)
                        .progressViewStyle(LinearProgressViewStyle())
                        .frame(height: 4)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.bullet")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .padding(.top, 50)
            
            VStack(spacing: 8) {
                Text(searchText.isEmpty && selectedFilter == .all ?
                     "No lists yet" : "No lists found")
                    .font(.headline)
                
                Text(searchText.isEmpty && selectedFilter == .all ?
                     "Create your first shopping list" :
                     "Try adjusting your search or filter")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            if searchText.isEmpty && selectedFilter == .all {
                Button(action: { showingCreateList = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create List")
                    }
                    .fontWeight(.semibold)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Clear Filters") {
                    withAnimation {
                        searchText = ""
                        selectedFilter = .all
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Filter Menu
    private var filterMenu: some View {
        Menu {
            Section("Filter") {
                ForEach(ListFilter.allCases, id: \.self) { filter in
                    Button {
                        withAnimation {
                            selectedFilter = filter
                        }
                    } label: {
                        Label(filter.rawValue, systemImage: filter.icon)
                    }
                }
            }
            
            Section("Sort") {
                ForEach(SortOrder.allCases, id: \.self) { order in
                    Button {
                        withAnimation {
                            sortOrder = order
                        }
                    } label: {
                        Text(order.rawValue)
                    }
                }
            }
        } label: {
            Image(systemName: "slider.horizontal.3")
                .font(.title2)
                .foregroundColor(selectedFilter == .all ? .primary : .blue)
        }
    }
    
    // MARK: - Swipe Actions
    @ViewBuilder
    private func swipeActions(for list: ShoppingList) -> some View {
        Button(role: .destructive) {
            Task {
                try? await listsViewModel.deleteList(list)
            }
        } label: {
            Label("Delete", systemImage: "trash")
        }
        
        Button {
            Task {
                try? await listsViewModel.toggleListCompletion(list)
            }
        } label: {
            Label(
                list.isCompleted ? "Mark Active" : "Mark Complete",
                systemImage: list.isCompleted ? "arrow.counterclockwise" : "checkmark"
            )
        }
        .tint(list.isCompleted ? .orange : .green)
    }
}
