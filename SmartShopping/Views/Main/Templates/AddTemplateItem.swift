//
//  AddTemplateItem.swift
//  SmartShopping
//
//  Created by user279038 on 12/2/25.
//

import SwiftUI

struct AddTemplateItemView: View {
    let onItemAdded: (TemplateItem) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var category = ""
    @State private var quantity = 1
    @State private var estimatedPrice = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
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
                        Text("Add to Template")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .disabled(name.isEmpty)
                    .foregroundColor(.white)
                    .listRowBackground(name.isEmpty ? Color.gray : Color.blue)
                }
            }
            .navigationTitle("Add Item")
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
    
    private func addItem() {
        let price: Double? = {
            if let doubleValue = Double(estimatedPrice), doubleValue > 0 {
                return doubleValue
            }
            return nil
        }()
        
        let newItem = TemplateItem(
            name: name,
            category: category.isEmpty ? nil : category,
            quantity: quantity,
            estimatedPrice: price,
            notes: notes.isEmpty ? nil : notes
        )
        
        onItemAdded(newItem)
        dismiss()
    }
}
