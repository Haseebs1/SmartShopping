//
//  ListDetailView.swift
//  SmartShopping
//
//  Created by user279038 on 12/1/25.
//


import SwiftUI

struct ListDetailView: View {
    @EnvironmentObject var listsViewModel: ListsViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showingAddItem = false
    @State private var editingItem: ShoppingItem?
    @State private var hasUnsavedChanges = false
    @State private var isLoading = false
    
    // Store the list ID
    let listId: String
    
    // Computed property to get the current list from ViewModel
    private var list: ShoppingList? {
        listsViewModel.lists.first { $0.id == listId }
    }
    
    init(list: ShoppingList) {
        self.listId = list.id
    }
    
    var body: some View {
        Group {
            if let list = list {
                listContent(for: list)
            } else if isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text("List not found")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        // Try to fetch lists if not found
                        Task {
                            await listsViewModel.fetchLists()
                        }
                    }
            }
        }
        .navigationTitle("List Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Load data if list not found
            if list == nil {
                Task {
                    await listsViewModel.fetchLists()
                }
            }
        }
    }
    
    private func listContent(for list: ShoppingList) -> some View {
        List {
            // Header
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(list.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Circle()
                            .fill(list.isCompleted ? Color.green : Color.blue)
                            .frame(width: 12, height: 12)
                    }
                    
                    if let description = list.description, !description.isEmpty {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    if let store = list.store, !store.isEmpty {
                        HStack {
                            Image(systemName: "building.2")
                            Text(store)
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                    
                    if let budget = list.budget, budget > 0 {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Budget")
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                Text("\(list.totalSpent, format: .currency(code: "USD")) / \(budget, format: .currency(code: "USD"))")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(budgetColor(for: list))
                            }
                            
                            ProgressView(value: min(list.totalSpent / budget, 1))
                                .tint(budgetColor(for: list))
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Stats
            Section("Statistics") {
                HStack {
                    StatRow(title: "Items", value: "\(list.items.count)", icon: "cart", color: .blue)
                    Divider()
                    StatRow(title: "Purchased", value: "\(purchasedCount(for: list))", icon: "checkmark.circle", color: .green)
                    Divider()
                    StatRow(title: "Progress", value: "\(Int(list.progress * 100))%", icon: "chart.bar", color: .orange)
                }
                .frame(height: 60)
            }
            
            // Items
            Section {
                if list.items.isEmpty {
                    emptyItemsView
                } else {
                    ForEach(list.items) { item in
                        ItemRow(
                            item: item,
                            onEdit: { editingItem = item },
                            onToggle: {
                                toggleItemPurchase(item, listId: listId)
                            }
                        )
                    }
                    .onDelete { indexSet in
                        deleteItems(at: indexSet, from: list)
                    }
                }
            } header: {
                HStack {
                    Text("Items")
                    Spacer()
                    Button {
                        showingAddItem = true
                    } label: {
                        Label("Add", systemImage: "plus.circle.fill")
                            .font(.subheadline)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if hasUnsavedChanges {
                    Button("Save") {
                        saveListChanges()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        
        .sheet(isPresented: $showingAddItem) {
            NavigationView {
                AddItemView(list: list) // Force unwrap is safe here because we only show the sheet when list exists
                    .environmentObject(listsViewModel)
            }
        }
        
        .sheet(item: $editingItem) { item in
            NavigationView {
                EditItemSheet(
                    item: item,
                    onSave: { updatedItem in
                        updateItem(updatedItem)
                    },
                    onDelete: {
                        deleteItem(item)
                    }
                )
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func purchasedCount(for list: ShoppingList) -> Int {
        list.items.filter { $0.isPurchased }.count
    }
    
    private func budgetColor(for list: ShoppingList) -> Color {
        guard let budget = list.budget, budget > 0 else { return .gray }
        let ratio = list.totalSpent / budget
        return ratio <= 0.7 ? .green : ratio <= 0.9 ? .orange : .red
    }
    
    private var emptyItemsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "cart")
                .font(.title)
                .foregroundColor(.gray)
            
            Text("No items yet")
                .font(.headline)
            
            Text("Add your first item")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
    
    private func toggleItemPurchase(_ item: ShoppingItem, listId: String) {
        Task {
            isLoading = true
            do {
                var updatedItem = item
                updatedItem.isPurchased.toggle()
                try await listsViewModel.updateItem(updatedItem)
                hasUnsavedChanges = true
            } catch {
                print("Error toggling item purchase: \(error)")
            }
            isLoading = false
        }
    }
    
    private func deleteItems(at offsets: IndexSet, from list: ShoppingList) {
        Task {
            isLoading = true
            do {
                // Get items to delete
                let itemsToDelete = offsets.compactMap { index in
                    list.items.indices.contains(index) ? list.items[index] : nil
                }
                
                // Delete each item
                for item in itemsToDelete {
                    try await listsViewModel.deleteItem(item)
                }
                
                hasUnsavedChanges = true
            } catch {
                print("Error deleting items: \(error)")
            }
            isLoading = false
        }
    }
    
    private func updateItem(_ item: ShoppingItem) {
        Task {
            isLoading = true
            do {
                try await listsViewModel.updateItem(item)
                hasUnsavedChanges = true
            } catch {
                print("Error updating item: \(error)")
            }
            isLoading = false
        }
    }
    
    private func deleteItem(_ item: ShoppingItem) {
        Task {
            isLoading = true
            do {
                try await listsViewModel.deleteItem(item)
                hasUnsavedChanges = true
            } catch {
                print("Error deleting item: \(error)")
            }
            isLoading = false
        }
    }
    
    private func saveListChanges() {
        guard let list = list else { return }
        
        Task {
            isLoading = true
            do {
                try await listsViewModel.updateList(list)
                hasUnsavedChanges = false
                dismiss()
            } catch {
                print("Error saving list: \(error)")
            }
            isLoading = false
        }
    }
}

// MARK: - Supporting Views

struct StatRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            Text(value)
                .font(.headline)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ItemRow: View {
    let item: ShoppingItem
    let onEdit: () -> Void
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            Button {
                onToggle()
            } label: {
                Image(systemName: item.isPurchased ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isPurchased ? .green : .gray)
                    .font(.title2)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.body)
                    .strikethrough(item.isPurchased)
                    .foregroundColor(item.isPurchased ? .secondary : .primary)
                
                if let notes = item.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            if let price = item.actualPrice ?? item.estimatedPrice {
                Text("\(price * Double(item.quantity), format: .currency(code: "USD"))")
                    .font(.body)
                    .foregroundColor(item.isPurchased ? .secondary : .primary)
            }
            
            Button {
                onEdit()
            } label: {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
                    .font(.callout)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}
