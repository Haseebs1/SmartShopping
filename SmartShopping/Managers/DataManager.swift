//
//  DataManager.swift
//  SmartShopping
//
//  Created by user279038 on 12/1/25.
//


import Foundation
import Combine

@MainActor
class DataManager: ObservableObject {
    static let shared = DataManager()
    
    private init() {}
    
    // Publishers to notify when data changes
    let listsDidChange = PassthroughSubject<Void, Never>()
    let itemsDidChange = PassthroughSubject<(listId: String, items: [ShoppingItem]), Never>()
    
    func notifyListsChanged() {
        listsDidChange.send()
    }
    
    func notifyItemsChanged(listId: String, items: [ShoppingItem]) {
        itemsDidChange.send((listId, items))
    }
}
