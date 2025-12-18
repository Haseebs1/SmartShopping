//
//  CreateTemplateView.swift
//  SmartShopping
//
//  Created by user279038 on 12/1/25.
//


import SwiftUI
import Supabase

 struct CreateTemplateView: View {
     @Environment(\.dismiss) var dismiss
     @EnvironmentObject var listsViewModel: ListsViewModel
     let onTemplateCreated: () -> Void
     
     @State private var name = ""
     @State private var description = ""
     @State private var category = "General"
     @State private var templateItems: [TemplateItem] = []
     @State private var showingAddItem = false
     @State private var isLoading = false
     @State private var showingError = false
     @State private var errorMessage = ""
     @State private var isPublic = false
     @State private var isFavorite = false
     
     var body: some View {
         NavigationView {
             Form {
                 Section(header: Text("Template Details")) {
                     TextField("Template Name *", text: $name)
                     TextField("Description (optional)", text: $description)
                     TextField("Category", text: $category)
                     
                     Toggle("Make Public", isOn: $isPublic)
                         .tint(.blue)
                     
                     Toggle("Add to Favorites", isOn: $isFavorite)
                         .tint(.yellow)
                 }
                 
                 Section(header: HStack {
                     Text("Template Items")
                     Spacer()
                     Text("\(templateItems.count) items")
                         .font(.caption)
                         .foregroundColor(.secondary)
                 }) {
                     if templateItems.isEmpty {
                         Text("No items yet")
                             .foregroundColor(.secondary)
                             .italic()
                     } else {
                         ForEach(templateItems) { item in
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
                         .onDelete { indexSet in
                             templateItems.remove(atOffsets: indexSet)
                         }
                     }
                     
                     Button {
                         showingAddItem = true
                     } label: {
                         Label("Add Item", systemImage: "plus.circle.fill")
                     }
                 }
                 
                 Section {
                     Button(action: createTemplate) {
                         if isLoading {
                             HStack {
                                 Spacer()
                                 ProgressView()
                                 Spacer()
                             }
                         } else {
                             Text("Create Template")
                                 .frame(maxWidth: .infinity)
                                 .fontWeight(.semibold)
                         }
                     }
                     .disabled(name.isEmpty || category.isEmpty || isLoading)
                     .foregroundColor(.white)
                     .listRowBackground(name.isEmpty || category.isEmpty || isLoading ? Color.gray : Color.blue)
                 }
             }
             .navigationTitle("New Template")
             .navigationBarTitleDisplayMode(.inline)
             .toolbar {
                 ToolbarItem(placement: .navigationBarLeading) {
                     Button("Cancel") {
                         dismiss()
                     }
                 }
             }
             .sheet(isPresented: $showingAddItem) {
                 AddTemplateItemView { newItem in
                     templateItems.append(newItem)
                 }
             }
             .alert("Error", isPresented: $showingError) {
                 Button("OK", role: .cancel) { }
             } message: {
                 Text(errorMessage)
             }
         }
     }
     
     private func createTemplate() {
         isLoading = true
         
         Task {
             do {
                 // Get current user ID
                 guard let userId = listsViewModel.supabase.currentUserId else {
                     throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
                 }
                 
                 // Create template with items
                 let newTemplate = ShoppingTemplate(
                     userId: userId,
                     name: name,
                     description: description.isEmpty ? nil : description,
                     category: category,
                     timesUsed: 0,
                     isFavorite: isFavorite,
                     isPublic: isPublic,
                     items: templateItems.isEmpty ? nil : templateItems
                 )
                 
                 print("Creating template: \(name) with \(templateItems.count) items")
                 
                 // Insert to database
                 let response: ShoppingTemplate = try await listsViewModel.supabase.database
                     .from("shopping_templates")
                     .insert(newTemplate)
                     .select()
                     .single()
                     .execute()
                     .value
                 
                 print("Template created successfully: \(response.id)")
                 
                 await MainActor.run {
                     isLoading = false
                     onTemplateCreated()
                     dismiss()
                 }
                 
             } catch {
                 print("Error creating template: \(error)")
                 
                 if let supabaseError = error as? PostgrestError {
                     print("Supabase Error Details:")
                     print("Message: \(supabaseError.message)")
                     print("Code: \(supabaseError.code ?? "No code")")
                     print("Hint: \(supabaseError.hint ?? "No hint")")
                 }
                 
                 await MainActor.run {
                     isLoading = false
                     errorMessage = error.localizedDescription
                     showingError = true
                 }
             }
         }
     }
 }
