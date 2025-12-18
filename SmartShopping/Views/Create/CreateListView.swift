//
//  CreateListView.swift
//  SmartShopping
//
//  Created by user279038 on 12/1/25.
//

import SwiftUI

struct CreateListView: View {
    @EnvironmentObject var listsViewModel: ListsViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var listName = ""
    @State private var listDescription = ""
    @State private var store = ""
    @State private var budget = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, description, store, budget
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("List Information")) {
                    TextField("List Name *", text: $listName)
                        .focused($focusedField, equals: .name)
                    
                    TextField("Description (optional)", text: $listDescription)
                        .focused($focusedField, equals: .description)
                    
                    TextField("Store (optional)", text: $store)
                        .focused($focusedField, equals: .store)
                    
                    HStack {
                        Text("$")
                            .foregroundColor(.gray)
                        TextField("Budget (optional)", text: $budget)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .budget)
                    }
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button(action: createList) {
                        if isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else {
                            Text("Create List")
                                .frame(maxWidth: .infinity)
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(listName.isEmpty || isLoading)
                    .foregroundColor(.white)
                    .listRowBackground(listName.isEmpty || isLoading ? Color.gray : Color.blue)
                }
            }
            .navigationTitle("New List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    focusedField = .name
                }
            }
        }
    }
    
    private func createList() {
        guard !listName.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let budgetValue = budget.isEmpty ? nil : Double(budget)
                _ = try await listsViewModel.createList(
                    name: listName,
                    description: listDescription.isEmpty ? nil : listDescription,
                    store: store.isEmpty ? nil : store,
                    budget: budgetValue
                )
                
                // Refresh the lists
                await listsViewModel.refresh()
                
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Error: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}
