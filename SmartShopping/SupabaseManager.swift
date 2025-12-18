//
//  SupabaseManager.swift
//  SmartShopping
//
//  Created by user279038 on 12/1/25.
//

import Foundation
import Supabase
import KeychainSwift

class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    private let keychain = KeychainSwift()
    
    private init() {
        self.client = SupabaseClient(
            supabaseURL: Config.supabaseURL,
            supabaseKey: Config.supabaseKey
        )
    }
    
    var auth: AuthClient {
        client.auth
    }
    
    var database: PostgrestClient {
        client.database
    }
    
    var realtime: RealtimeClient {
        client.realtime
    }
    
    var isAuthenticated: Bool {
        return client.auth.currentSession != nil
    }
    
    var currentUserId: String? {
        return client.auth.currentSession?.user.id.uuidString
    }
    
    var currentUserEmail: String? {
        return client.auth.currentSession?.user.email
    }
    
    // Save session for persistence
    func saveSession(_ session: Session) {
        if let data = try? JSONEncoder().encode(session) {
            keychain.set(data, forKey: "supabase_session")
        }
    }
    
    func loadSession() -> Session? {
        guard let data = keychain.getData("supabase_session") else { return nil }
        return try? JSONDecoder().decode(Session.self, from: data)
    }
    
    func clearSession() {
        keychain.delete("supabase_session")
    }
}
