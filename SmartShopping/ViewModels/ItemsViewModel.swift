//
//  ItemsViewModel.swift
//  SmartShopping
//
//  Created by user279038 on 12/1/25.
//


/*import Foundation
import Combine
import Supabase

@MainActor
class ItemsViewModel: ObservableObject {
    @Published var items: [ShoppingItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseManager.shared
    
    func fetchItems(for listId: String) async {
        guard let userId = supabase.currentUserId else {
            errorMessage = "Not authenticated"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let items: [ShoppingItem] = try await supabase.database
                .from("shopping_items")
                .select()
                .eq("list_id", value: listId)
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            self.items = items
            isLoading = false
        } catch {
            errorMessage = "Failed to load items: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func createItem(_ item: ShoppingItem) async throws -> ShoppingItem {
        let createdItem: ShoppingItem = try await supabase.database
            .from("shopping_items")
            .insert(item)
            .select()
            .single()
            .execute()
            .value
        
        items.insert(createdItem, at: 0)
        return createdItem
    }
    
    
    
    func updateItem(_ item: ShoppingItem) async throws -> ShoppingItem {
        var updatedItem = item
        updatedItem.updatedAt = Date()
        
        let result: ShoppingItem = try await supabase.database
            .from("shopping_items")
            .update(updatedItem)
            .eq("id", value: item.id)
            .select()
            .single()
            .execute()
            .value
        
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = result
        }
        
        return result
    }
    
    func deleteItem(_ item: ShoppingItem) async throws {
        try await supabase.database
            .from("shopping_items")
            .delete()
            .eq("id", value: item.id)
            .execute()
        
        items.removeAll { $0.id == item.id }
    }
    
    func togglePurchaseStatus(_ item: ShoppingItem) async throws {
        var updatedItem = item
        updatedItem.isPurchased.toggle()
        updatedItem.updatedAt = Date()
        
        _ = try await updateItem(updatedItem)
    }
    
    func updatePrice(_ item: ShoppingItem, actualPrice: Double) async throws {
        var updatedItem = item
        updatedItem.actualPrice = actualPrice
        updatedItem.updatedAt = Date()
        
        _ = try await updateItem(updatedItem)
    }
}*/
