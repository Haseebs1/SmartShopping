//
//  UseTemplateView.swift
//  SmartShopping
//
//  Created by user279038 on 12/1/25.
//

import SwiftUI
import Supabase

// MARK: - Use Template View
struct UseTemplateView: View {
    let template: ShoppingTemplate
    @ObservedObject var listsViewModel: ListsViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var listName: String = ""
    @State private var isLoading = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    init(template: ShoppingTemplate, listsViewModel: ListsViewModel) {
        self.template = template
        self.listsViewModel = listsViewModel
        _listName = State(initialValue: "\(template.name) List")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("List Details")) {
                    TextField("List Name", text: $listName)
                }
                
                Section(header: Text("Items from Template")) {
                    if let items = template.items, !items.isEmpty {
                        ForEach(items) { item in
                            HStack {
                                Text(item.name)
                                Spacer()
                                Text("×\(item.quantity)")
                                    .foregroundColor(.secondary)
                                if let price = item.estimatedPrice {
                                    Text(String(format: "$%.2f", price))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    } else {
                        Text("No items in this template")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button(action: createListFromTemplate) {
                        if isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else {
                            Text("Create Shopping List")
                                .frame(maxWidth: .infinity)
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(listName.isEmpty || isLoading)
                    .foregroundColor(.white)
                    .listRowBackground(listName.isEmpty || isLoading ? Color.gray : Color.blue)
                }
            }
            .navigationTitle("Use Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func createListFromTemplate() {
        isLoading = true
        
        Task {
            do {
                // Create the list first
                let newList = try await listsViewModel.createList(
                    name: listName,
                    description: template.description,
                    store: nil,
                    budget: nil
                )
                
                // Add all template items to the new list
                if let items = template.items {
                    for templateItem in items {
                        let shoppingItem = ShoppingItem(
                            listId: newList.id,
                            userId: newList.userId,
                            name: templateItem.name,
                            category: templateItem.category,
                            quantity: templateItem.quantity,
                            estimatedPrice: templateItem.estimatedPrice,
                            notes: templateItem.notes
                        )
                        
                        _ = try await listsViewModel.createItem(shoppingItem, for: newList.id)
                    }
                }
                
                // Increment times used counter
                try await incrementTemplateUsage()
                
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                print("Error creating list from template: \(error)")
                
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
    
    private func incrementTemplateUsage() async throws {
        // Only increment if it's a user template (has a valid ID from database)
        if !template.id.isEmpty && template.id != "demo_user" {
            let currentTimesUsed = template.timesUsed
            try await listsViewModel.supabase.database
                .from("shopping_templates")
                .update(["times_used": currentTimesUsed + 1])
                .eq("id", value: template.id)
                .execute()
        }
    }
}
