//
//  ShoppingList.swift
//  SmartShopping
//
//  Created by user279038 on 12/1/25.
//


import Foundation
import Combine

class ShoppingList: Identifiable, ObservableObject, Hashable, Codable {
    let id: String
    let userId: String
    @Published var name: String
    @Published var description: String?
    @Published var store: String?
    @Published var budget: Double?
    @Published var totalSpent: Double
    @Published var isCompleted: Bool
    let createdAt: Date
    @Published var completedAt: Date?
    @Published var items: [ShoppingItem] = []

    // MARK: - Codable Coding Keys
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case description
        case store
        case budget
        case totalSpent = "total_spent"
        case isCompleted = "is_completed"
        case createdAt = "created_at"
        case completedAt = "completed_at"
        case items
    }

    // MARK: - Initializer
    init(id: String = UUID().uuidString,
         userId: String,
         name: String,
         description: String? = nil,
         store: String? = nil,
         budget: Double? = nil,
         totalSpent: Double = 0,
         isCompleted: Bool = false,
         createdAt: Date = Date(),
         completedAt: Date? = nil,
         items: [ShoppingItem] = []) {
        self.id = id
        self.userId = userId
        self.name = name
        self.description = description
        self.store = store
        self.budget = budget
        self.totalSpent = totalSpent
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.items = items
    }

    // MARK: - Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        store = try container.decodeIfPresent(String.self, forKey: .store)
        budget = try container.decodeIfPresent(Double.self, forKey: .budget)
        totalSpent = try container.decode(Double.self, forKey: .totalSpent)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        
        // Decode dates
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        createdAt = dateFormatter.date(from: createdAtString) ?? Date()
        
        if let completedAtString = try container.decodeIfPresent(String.self, forKey: .completedAt) {
            completedAt = dateFormatter.date(from: completedAtString)
        } else {
            completedAt = nil
        }
        
        items = try container.decode([ShoppingItem].self, forKey: .items)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(store, forKey: .store)
        try container.encodeIfPresent(budget, forKey: .budget)
        try container.encode(totalSpent, forKey: .totalSpent)
        try container.encode(isCompleted, forKey: .isCompleted)
        
        // Encode dates
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        try container.encode(dateFormatter.string(from: createdAt), forKey: .createdAt)
        
        if let completedAt = completedAt {
            try container.encode(dateFormatter.string(from: completedAt), forKey: .completedAt)
        }
        
        try container.encode(items, forKey: .items)
    }

    // MARK: - Hashable
    static func == (lhs: ShoppingList, rhs: ShoppingList) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // MARK: - Computed Properties
    var progress: Double {
        guard !items.isEmpty else { return 0 }
        let purchased = items.filter { $0.isPurchased }.count
        return Double(purchased) / Double(items.count)
    }

    var formattedBudget: String {
        guard let budget = budget else { return "No budget" }
        return String(format: "$%.2f", budget)
    }
}
