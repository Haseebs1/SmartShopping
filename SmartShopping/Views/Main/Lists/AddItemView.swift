//
//  AddItemView.swift
//  SmartShopping
//
//  Created by user279038 on 12/1/25.
//

import SwiftUI
internal import Auth

struct AddItemView: View {
    let list: ShoppingList
    @EnvironmentObject var listsViewModel: ListsViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var category = ""
    @State private var quantity = 1
    @State private var estimatedPrice = ""
    @State private var notes = ""
    @State private var isLoading = false
    
    var body: some View {
        Form {
            Section(header: Text("Item Details")) {
                TextField("Item Name *", text: $name)
                
                TextField("Category (optional)", text: $category)
                
                Stepper("Quantity: \(quantity)", value: $quantity, in: 1...100)
                
                HStack {
                    Text("$").foregroundColor(.gray)
                    TextField("Estimated Price (optional)", text: $estimatedPrice)
                        .keyboardType(.decimalPad)
                }
                
                TextField("Notes (optional)", text: $notes)
            }
            
            Section {
                Button(action: addItem) {
                    if isLoading {
                        HStack { Spacer(); ProgressView(); Spacer() }
                    } else {
                        Text("Add Item")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                }
                .disabled(name.isEmpty || isLoading)
                .foregroundColor(.white)
                .listRowBackground(name.isEmpty || isLoading ? Color.gray : Color.blue)
            }
        }
        .navigationTitle("Add Item")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") { dismiss() }
            }
        }
    }
    
    private func addItem() {
        isLoading = true
        
        Task {
            do {
                guard let userId = SupabaseManager.shared.auth.currentUser?.id.uuidString else {
                    throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
                }
                
                let newItem = ShoppingItem(
                    listId: list.id,
                    userId: userId,
                    name: name,
                    category: category.isEmpty ? nil : category,
                    quantity: quantity,
                    estimatedPrice: estimatedPrice.isEmpty ? nil : Double(estimatedPrice),
                    notes: notes.isEmpty ? nil : notes
                )
                
                let createdItem = try await listsViewModel.createItem(newItem, for: list.id)
                
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    print("Error adding item: \(error)")
                }
            }
        }
    }
}
