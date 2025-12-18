//
//  SmartShoppingApp.swift
//  SmartShopping
//
//  Created by user279038 on 12/1/25.
//


/*import SwiftUI

@main
struct SmartShoppingApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var sharedListsViewModel = ListsViewModel()
    @StateObject private var templatesViewModel = TemplatesViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    ContentView()
                        .environmentObject(authViewModel)
                        .environmentObject(sharedListsViewModel)
                        .environmentObject(templatesViewModel)
                } else {
                    LoginView()
                        .environmentObject(authViewModel)
                }
            }
            .onAppear {
                authViewModel.checkAuth()
            }
        }
    }
}*/

import SwiftUI

@main
struct SmartShoppingApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var sharedListsViewModel = ListsViewModel()
    @StateObject private var templatesViewModel = TemplatesViewModel()
    
    @State private var showSplashScreen = true

    var body: some Scene {
        WindowGroup {
            if showSplashScreen {
                SplashScreenView()
                    .onAppear {
                        authViewModel.checkAuth()
                        
                        // Hide splash screen after delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation {
                                showSplashScreen = false
                            }
                        }
                    }
            } else {
                Group {
                    if authViewModel.isAuthenticated {
                        ContentView()
                            .environmentObject(authViewModel)
                            .environmentObject(sharedListsViewModel)
                            .environmentObject(templatesViewModel)
                    } else {
                        LoginView()
                            .environmentObject(authViewModel)
                    }
                }
                .transition(.opacity)
            }
        }
    }
}
