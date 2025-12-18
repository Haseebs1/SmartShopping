//
//  EditItemSheet.swift
//  SmartShopping
//
//  Created by user279038 on 12/1/25.
//

import SwiftUI

struct EditItemSheet: View {
    @Environment(\.dismiss) var dismiss
    let item: ShoppingItem
    let onSave: (ShoppingItem) -> Void
    let onDelete: () -> Void
    
    @State private var name: String
    @State private var category: String
    @State private var quantity: Int
    @State private var estimatedPrice: String
    @State private var actualPrice: String
    @State private var notes: String
    @State private var isLoading = false
    
    init(item: ShoppingItem, onSave: @escaping (ShoppingItem) -> Void, onDelete: @escaping () -> Void) {
        self.item = item
        self.onSave = onSave
        self.onDelete = onDelete
        
        _name = State(initialValue: item.name)
        _category = State(initialValue: item.category ?? "")
        _quantity = State(initialValue: item.quantity)
        _estimatedPrice = State(initialValue: item.estimatedPrice != nil ? String(format: "%.2f", item.estimatedPrice!) : "")
        _actualPrice = State(initialValue: item.actualPrice != nil ? String(format: "%.2f", item.actualPrice!) : "")
        _notes = State(initialValue: item.notes ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Name", text: $name)
                    
                    TextField("Category (optional)", text: $category)
                    
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...100)
                }
                
                Section(header: Text("Pricing")) {
                    HStack {
                        Text("Estimated: $")
                            .foregroundColor(.gray)
                        TextField("0.00", text: $estimatedPrice)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Text("Actual: $")
                            .foregroundColor(.gray)
                        TextField("0.00", text: $actualPrice)
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                Section {
                    Button(action: updateItem) {
                        if isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else {
                            Text("Save Changes")
                                .frame(maxWidth: .infinity)
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(name.isEmpty || isLoading)
                    .foregroundColor(.white)
                    .listRowBackground(name.isEmpty || isLoading ? Color.gray : Color.blue)
                    
                    Button(role: .destructive, action: deleteItem) {
                        Text("Delete Item")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func updateItem() {
        isLoading = true
        
        // Create updated item
        var updatedItem = item
        updatedItem.name = name
        updatedItem.category = category.isEmpty ? nil : category
        updatedItem.quantity = quantity
        updatedItem.estimatedPrice = estimatedPrice.isEmpty ? nil : Double(estimatedPrice)
        updatedItem.actualPrice = actualPrice.isEmpty ? nil : Double(actualPrice)
        updatedItem.notes = notes.isEmpty ? nil : notes
        updatedItem.updatedAt = Date()
        
        onSave(updatedItem)
        
        isLoading = false
        dismiss()
    }
    
    private func deleteItem() {
        onDelete()
        dismiss()
    }
}
