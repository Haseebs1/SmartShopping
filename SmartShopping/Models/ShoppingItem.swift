//
//  ShoppingItem.swift
//  SmartShopping
//
//  Created by user279038 on 12/1/25.
//

import Foundation

struct ShoppingItem: Codable, Identifiable, Equatable, Hashable {
    let id: String
    var listId: String       
    var userId: String
    var name: String
    var category: String?
    var quantity: Int
    var unit: String
    var estimatedPrice: Double?
    var actualPrice: Double?
    var isPurchased: Bool
    var notes: String?
    var barcode: String?
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, name, category, quantity, unit, notes, barcode
        case listId = "list_id"
        case userId = "user_id"
        case estimatedPrice = "estimated_price"
        case actualPrice = "actual_price"
        case isPurchased = "is_purchased"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(id: String = UUID().uuidString,
         listId: String,
         userId: String,
         name: String,
         category: String? = nil,
         quantity: Int = 1,
         unit: String = "pcs",
         estimatedPrice: Double? = nil,
         actualPrice: Double? = nil,
         isPurchased: Bool = false,
         notes: String? = nil,
         barcode: String? = nil,
         createdAt: Date = Date(),
         updatedAt: Date? = nil) {
        self.id = id
        self.listId = listId
        self.userId = userId
        self.name = name
        self.category = category
        self.quantity = quantity
        self.unit = unit
        self.estimatedPrice = estimatedPrice
        self.actualPrice = actualPrice
        self.isPurchased = isPurchased
        self.notes = notes
        self.barcode = barcode
        self.createdAt = createdAt
        self.updatedAt = updatedAt ?? createdAt
    }
    
    static func == (lhs: ShoppingItem, rhs: ShoppingItem) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension ShoppingItem {
    var totalPrice: Double {
        (actualPrice ?? estimatedPrice ?? 0) * Double(quantity)
    }
    
    var formattedPrice: String {
        String(format: "$%.2f", totalPrice)
    }
}
