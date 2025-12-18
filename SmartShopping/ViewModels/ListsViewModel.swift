//
//  ListsViewModel.swift
//  SmartShopping
//
//  Created by user279038 on 12/1/25.
//

import Foundation
import Combine
import Supabase

@MainActor
class ListsViewModel: ObservableObject {
    @Published var lists: [ShoppingList] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    let supabase = SupabaseManager.shared
    private let cacheKey = "cached_shopping_lists"
    
    // MARK: - Initialization
    init() {
        // Load cached data on initialization
        loadCachedData()
        
        // Fetch fresh data from server
        Task {
            await fetchLists()
        }
    }
    
    // MARK: - Local Cache Management
    private func loadCachedData() {
        if let data = UserDefaults.standard.data(forKey: cacheKey) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                let cachedLists = try decoder.decode([ShoppingList].self, from: data)
                if !cachedLists.isEmpty {
                    self.lists = cachedLists
                    print("Loaded \(cachedLists.count) lists from cache")
                }
            } catch {
                print("Error loading cached lists: \(error)")
            }
        }
    }
    
    private func saveToCache() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let data = try encoder.encode(lists)
            UserDefaults.standard.set(data, forKey: cacheKey)
            print("Saved \(lists.count) lists to cache")
        } catch {
            print("Error saving lists to cache: \(error)")
        }
    }
    
    private func clearCache() {
        UserDefaults.standard.removeObject(forKey: cacheKey)
    }
    
    // MARK: - Item Management
    func createItem(_ item: ShoppingItem, for listId: String) async throws -> ShoppingItem {
        let response: ShoppingItem = try await supabase.database
            .from("shopping_items")
            .insert(item)
            .select()
            .single()
            .execute()
            .value

        // Update the local list
        if let listIndex = lists.firstIndex(where: { $0.id == listId }) {
            // Create a new ShoppingList instance to trigger SwiftUI update
            var updatedList = lists[listIndex]
            updatedList.items.append(response)
            
            // Update total spent
            updatedList.totalSpent = updatedList.items.reduce(0) { $0 + ($1.totalPrice ?? 0) }
            
            lists[listIndex] = updatedList
        }

        // Save to cache
        saveToCache()
        
        return response
    }

    func updateItem(_ item: ShoppingItem) async throws {
        _ = try await supabase.database
            .from("shopping_items")
            .update(item)
            .eq("id", value: item.id)
            .execute()

        // Update the item in all lists
        for (listIndex, var list) in lists.enumerated() {
            if let itemIndex = list.items.firstIndex(where: { $0.id == item.id }) {
                list.items[itemIndex] = item
                // Update total spent
                list.totalSpent = list.items.reduce(0) { $0 + ($1.totalPrice ?? 0) }
                lists[listIndex] = list
                break
            }
        }
        
        // Save to cache
        saveToCache()
    }

    func deleteItem(_ item: ShoppingItem) async throws {
        try await supabase.database
            .from("shopping_items")
            .delete()
            .eq("id", value: item.id)
            .execute()

        // Remove the item from all lists
        for (listIndex, var list) in lists.enumerated() {
            list.items.removeAll { $0.id == item.id }
            // Update total spent
            list.totalSpent = list.items.reduce(0) { $0 + ($1.totalPrice ?? 0) }
            lists[listIndex] = list
        }
        
        // Save to cache
        saveToCache()
    }

    // MARK: - Fetch Lists
    func fetchLists() async {
        guard let userId = supabase.currentUserId else {
            errorMessage = "Not authenticated"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            struct DBShoppingList: Codable {
                let id: String
                let userId: String
                let name: String
                let description: String?
                let store: String?
                let budget: Double?
                let isCompleted: Bool
                let createdAt: Date
                let completedAt: Date?
                let totalSpent: Double

                enum CodingKeys: String, CodingKey {
                    case id
                    case userId = "user_id"
                    case name, description, store, budget
                    case isCompleted = "is_completed"
                    case createdAt = "created_at"
                    case completedAt = "completed_at"
                    case totalSpent = "total_spent"
                }
            }

            let dbLists: [DBShoppingList] = try await supabase.database
                .from("shopping_lists")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .execute()
                .value

            var fetchedLists: [ShoppingList] = []

            for dbList in dbLists {
                let items: [ShoppingItem] = try await supabase.database
                    .from("shopping_items")
                    .select()
                    .eq("list_id", value: dbList.id)
                    .execute()
                    .value

                let totalSpent = items.reduce(0) { $0 + ($1.totalPrice ?? 0) }

                fetchedLists.append(
                    ShoppingList(
                        id: dbList.id,
                        userId: dbList.userId,
                        name: dbList.name,
                        description: dbList.description,
                        store: dbList.store,
                        budget: dbList.budget,
                        totalSpent: totalSpent,
                        isCompleted: dbList.isCompleted,
                        createdAt: dbList.createdAt,
                        completedAt: dbList.completedAt,
                        items: items
                    )
                )
            }

            self.lists = fetchedLists
            // Save fresh data to cache
            saveToCache()
            
        } catch {
            self.errorMessage = "Failed to load lists: \(error.localizedDescription)"
            // Keep using cached data if fetch fails
            print("Using cached data due to fetch error: \(error)")
        }

        isLoading = false
    }

    // MARK: - Create List
    func createList(
        name: String,
        description: String? = nil,
        store: String? = nil,
        budget: Double? = nil
    ) async throws -> ShoppingList {
        guard let userId = supabase.currentUserId else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }

        let now = Date()
        let newId = UUID().uuidString

        struct CreateListRequest: Codable {
            let id: String
            let userId: String
            let name: String
            let description: String?
            let store: String?
            let budget: Double?
            let isCompleted: Bool
            let createdAt: Date
            let totalSpent: Double

            enum CodingKeys: String, CodingKey {
                case id
                case userId = "user_id"
                case name, description, store, budget
                case isCompleted = "is_completed"
                case createdAt = "created_at"
                case totalSpent = "total_spent"
            }
        }

        let request = CreateListRequest(
            id: newId,
            userId: userId,
            name: name,
            description: description,
            store: store,
            budget: budget,
            isCompleted: false,
            createdAt: now,
            totalSpent: 0
        )

        _ = try await supabase.database
            .from("shopping_lists")
            .insert(request)
            .execute()

        let newList = ShoppingList(
            id: newId,
            userId: userId,
            name: name,
            description: description,
            store: store,
            budget: budget,
            totalSpent: 0,
            isCompleted: false,
            createdAt: now,
            completedAt: nil,
            items: []
        )

        lists.insert(newList, at: 0)
        // Save to cache
        saveToCache()
        
        return newList
    }

    // MARK: - Update List
    func updateList(_ list: ShoppingList) async throws {
        struct UpdateListRequest: Codable {
            let name: String
            let description: String?
            let store: String?
            let budget: Double?
            let isCompleted: Bool
            let totalSpent: Double
            let completedAt: Date?

            enum CodingKeys: String, CodingKey {
                case name, description, store, budget
                case isCompleted = "is_completed"
                case totalSpent = "total_spent"
                case completedAt = "completed_at"
            }
        }

        let request = UpdateListRequest(
            name: list.name,
            description: list.description,
            store: list.store,
            budget: list.budget,
            isCompleted: list.isCompleted,
            totalSpent: list.totalSpent,
            completedAt: list.completedAt
        )

        _ = try await supabase.database
            .from("shopping_lists")
            .update(request)
            .eq("id", value: list.id)
            .execute()

        if let index = lists.firstIndex(where: { $0.id == list.id }) {
            lists[index] = list
            // Save to cache
            saveToCache()
        }
    }

    // MARK: - Delete List
    func deleteList(_ list: ShoppingList) async throws {
        try await supabase.database
            .from("shopping_items")
            .delete()
            .eq("list_id", value: list.id)
            .execute()

        try await supabase.database
            .from("shopping_lists")
            .delete()
            .eq("id", value: list.id)
            .execute()

        lists.removeAll { $0.id == list.id }
        // Save to cache
        saveToCache()
    }

    // MARK: - Toggle Completion
    func toggleListCompletion(_ list: ShoppingList) async throws {
        var updatedList = list
        updatedList.isCompleted.toggle()
        updatedList.completedAt = updatedList.isCompleted ? Date() : nil
        try await updateList(updatedList)
    }

    // MARK: - Refresh
    func refresh() async {
        await fetchLists()
    }
    
    // MARK: - Manual Cache Management (for debugging)
    func clearAllData() {
        lists = []
        clearCache()
    }
}
