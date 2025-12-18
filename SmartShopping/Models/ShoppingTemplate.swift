//
//  ShoppingTemplate.swift
//  SmartShopping
//
//  Created by user279038 on 12/1/25.
//
// Models/ShoppingTemplate.swift

import Foundation

struct ShoppingTemplate: Codable, Identifiable, Equatable, Hashable {
    let id: String
    let userId: String
    var name: String
    var description: String?
    var category: String
    var timesUsed: Int
    var isFavorite: Bool
    var isPublic: Bool
    let createdAt: Date
    var updatedAt: Date
    var items: [TemplateItem]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, category, items
        case userId = "user_id"
        case timesUsed = "times_used"
        case isFavorite = "is_favorite"
        case isPublic = "is_public"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(id: String = UUID().uuidString,
         userId: String,
         name: String,
         description: String? = nil,
         category: String = "General",
         timesUsed: Int = 0,
         isFavorite: Bool = false,
         isPublic: Bool = false,
         createdAt: Date = Date(),
         updatedAt: Date = Date(),
         items: [TemplateItem]? = nil) {
        self.id = id
        self.userId = userId
        self.name = name
        self.description = description
        self.category = category
        self.timesUsed = timesUsed
        self.isFavorite = isFavorite
        self.isPublic = isPublic
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.items = items
    }
    
    // Custom decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        category = try container.decode(String.self, forKey: .category)
        timesUsed = try container.decodeIfPresent(Int.self, forKey: .timesUsed) ?? 0
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        isPublic = try container.decodeIfPresent(Bool.self, forKey: .isPublic) ?? false
        
        // Decode dates with flexible format
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let createdAtString = try container.decodeIfPresent(String.self, forKey: .createdAt),
           let date = dateFormatter.date(from: createdAtString) {
            createdAt = date
        } else {
            createdAt = Date()
        }
        
        if let updatedAtString = try container.decodeIfPresent(String.self, forKey: .updatedAt),
           let date = dateFormatter.date(from: updatedAtString) {
            updatedAt = date
        } else {
            updatedAt = Date()
        }
        
        // Custom handling for items JSON
        if let itemsJSONString = try? container.decodeIfPresent(String.self, forKey: .items),
           let itemsData = itemsJSONString.data(using: .utf8) {
            let jsonDecoder = JSONDecoder()
            items = try? jsonDecoder.decode([TemplateItem].self, from: itemsData)
        } else {
            items = nil
        }
    }
    
    // Custom encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(category, forKey: .category)
        try container.encode(timesUsed, forKey: .timesUsed)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(isPublic, forKey: .isPublic)
        
        // Encode dates as ISO8601 strings
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        try container.encode(dateFormatter.string(from: createdAt), forKey: .createdAt)
        try container.encode(dateFormatter.string(from: updatedAt), forKey: .updatedAt)
        
        // Custom handling for items JSON
        if let items = items {
            let jsonEncoder = JSONEncoder()
            let itemsData = try jsonEncoder.encode(items)
            if let itemsJSONString = String(data: itemsData, encoding: .utf8) {
                try container.encode(itemsJSONString, forKey: .items)
            }
        } else {
            try container.encodeNil(forKey: .items)
        }
    }
    
    static func == (lhs: ShoppingTemplate, rhs: ShoppingTemplate) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension ShoppingTemplate {
    var totalItems: Int {
        items?.count ?? 0
    }
}
