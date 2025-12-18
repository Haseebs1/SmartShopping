//
//  AuthViewModel.swift
//  SmartShopping
//
//  Created by user279038 on 12/1/25.
//


import Foundation
import Supabase
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUserEmail: String = ""
    @Published var currentUserId: String = ""
    
    private let supabase = SupabaseManager.shared
    
    init() {
        checkAuth()
    }
    
    func checkAuth() {
        if let session = supabase.loadSession() {
            // Try to restore session from keychain
            Task {
                do {
                    // Set the session with both tokens
                    try await supabase.client.auth.setSession(
                        accessToken: session.accessToken,
                        refreshToken: session.refreshToken
                    )
                    
                    // Get the current session to verify it's valid
                    let currentSession = try await supabase.auth.session
                    
                    currentUserEmail = currentSession.user.email ?? ""
                    currentUserId = currentSession.user.id.uuidString
                    isAuthenticated = true
                } catch {
                    print("Session restore failed: \(error)")
                    supabase.clearSession()
                    isAuthenticated = false
                    currentUserEmail = ""
                    currentUserId = ""
                }
            }
        }
    }
    
    func signIn(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let session = try await supabase.auth.signIn(email: email, password: password)
            supabase.saveSession(session)
            
            currentUserEmail = email
            currentUserId = session.user.id.uuidString
            isAuthenticated = true
            isLoading = false
            return true
        } catch {
            errorMessage = "Login failed: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    func signUp(email: String, password: String, name: String? = nil) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            // Create user data dictionary with AnyJSON
            var userData: [String: AnyJSON]? = nil
            if let name = name, !name.isEmpty {
                userData = ["full_name": .string(name)]
            }
            
            let response = try await supabase.auth.signUp(
                email: email,
                password: password,
                data: userData
            )
            
            if let session = response.session {
                supabase.saveSession(session)
                currentUserEmail = email
                currentUserId = response.user.id.uuidString
                isAuthenticated = true
                errorMessage = "Account created successfully!"
                isLoading = false
                return true
            } else {
                // Email confirmation required
                errorMessage = "Please check your email to confirm your account."
                isLoading = false
                return false
            }
        } catch {
            errorMessage = "Sign up failed: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            supabase.clearSession()
            isAuthenticated = false
            currentUserEmail = ""
            currentUserId = ""
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func resetPassword(email: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabase.auth.resetPasswordForEmail(email)
            errorMessage = "Password reset email sent to \(email)"
            isLoading = false
            return true
        } catch {
            errorMessage = "Failed to send reset email: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
}
