//
//  ProfileView.swift
//  SmartShopping
//
//  Created by user279038 on 12/1/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var listsViewModel: ListsViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showingSignOutAlert = false
    @State private var showingDeleteAccountAlert = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            Form {
                // Profile Section
                Section {
                    HStack(spacing: 15) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(authViewModel.currentUserEmail.components(separatedBy: "@").first ?? "User")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(authViewModel.currentUserEmail)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                // Stats Section
                Section(header: Text("Statistics")) {
                    LabeledContent("Total Lists", value: "\(listsViewModel.lists.count)")
                    LabeledContent("Active Lists",
                                 value: "\(listsViewModel.lists.filter { !$0.isCompleted }.count)")
                    LabeledContent("Completed Lists",
                                 value: "\(listsViewModel.lists.filter { $0.isCompleted }.count)")
                    
                    let totalItems = listsViewModel.lists.reduce(0) { $0 + ($1.items.count ?? 0) }
                    LabeledContent("Total Items", value: "\(totalItems)")
                    
                    let totalSpent = listsViewModel.lists.reduce(0) { $0 + $1.totalSpent }
                    LabeledContent("Total Spent",
                                 value: String(format: "$%.2f", totalSpent))
                }
                
                // Settings Section
                Section(header: Text("Settings")) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Label("Preferences", systemImage: "gear")
                    }
                    
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("About", systemImage: "info.circle")
                    }
                    
                    NavigationLink {
                        HelpView()
                    } label: {
                        Label("Help & Support", systemImage: "questionmark.circle")
                    }
                }
                
                // Account Section
                Section {
                    Button(role: .destructive) {
                        showingSignOutAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                        }
                    }
                    
                    Button(role: .destructive) {
                        showingDeleteAccountAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "person.crop.circle.badge.xmark")
                            Text("Delete Account")
                        }
                    }
                }
                
                // App Info
                Section(footer: Text("Smart Shopping v1.0.0\n© 2025 All rights reserved")) {
                    EmptyView()
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Delete Account", isPresented: $showingDeleteAccountAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    // TODO: Implement account deletion
                }
            } message: {
                Text("This action cannot be undone. All your data will be permanently deleted.")
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
                }
            }
        }
    }
    
    private func signOut() {
        isLoading = true
        Task {
            await authViewModel.signOut()
            await MainActor.run {
                isLoading = false
                dismiss()
            }
        }
    }
}

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("hapticFeedback") private var hapticFeedback = true
    @AppStorage("defaultListBudget") private var defaultListBudget = ""
    @AppStorage("currencySymbol") private var currencySymbol = "$"
    @AppStorage("defaultQuantity") private var defaultQuantity = 1
    
    var body: some View {
        Form {
            Section(header: Text("Notifications")) {
                Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    .tint(.blue)
                
                if notificationsEnabled {
                    Toggle("Shopping Reminders", isOn: .constant(true))
                        .disabled(true)
                    
                    Toggle("Budget Alerts", isOn: .constant(true))
                        .disabled(true)
                }
            }
            
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                Image(systemName: "cart.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                    .padding(.top, 30)
                
                Text("Smart Shopping")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Version 1.0.0")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("About")
                        .font(.headline)
                    
                    Text("Smart Shopping is your go to shopping app that helps you organize your shopping lists, track your expenses, and save time with reusable templates.")
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Text("Features")
                        .font(.headline)
                        .padding(.top, 10)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        FeatureRow(icon: "list.bullet",
                                 title: "Smart Lists",
                                 description: "Create and manage multiple shopping lists")
                        
                        FeatureRow(icon: "square.grid.2x2",
                                 title: "Templates",
                                 description: "Save and reuse your favorite shopping lists")
                        
                        FeatureRow(icon: "chart.bar.fill",
                                 title: "Analytics",
                                 description: "Track your spending and shopping habits")
                        
                        FeatureRow(icon: "dollarsign.circle",
                                 title: "Budget Tracking",
                                 description: "Stay on budget with real-time tracking")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                .padding(.horizontal)
                
                VStack(spacing: 10) {
                    Text("Developed by Haseeb")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("© 2025 Smart Shopping. All rights reserved.")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                
                Spacer(minLength: 50)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}

struct HelpView: View {
    @State private var searchText = ""
    
    let faqs = [
        FAQ(question: "How do I create a new list?",
            answer: "Tap the '+' button in the Lists tab or Home screen, then enter your list details."),
        FAQ(question: "How do I add items to a list?",
            answer: "Open a list and tap the '+' button in the top right corner."),
        FAQ(question: "What are templates?",
            answer: "Templates are reusable lists that you can save and use multiple times."),
        FAQ(question: "How do I mark an item as purchased?",
            answer: "Tap the circle next to an item to mark it as purchased."),
        FAQ(question: "Can I share my lists?",
            answer: "Currently, list sharing is not available but will be added in a future update."),
        FAQ(question: "How do I set a budget?",
            answer: "When creating or editing a list, you can enter a budget amount."),
        FAQ(question: "Where can I see my spending statistics?",
            answer: "Go to the Analytics tab to view your spending patterns and statistics."),
    ]
    
    var filteredFAQs: [FAQ] {
        if searchText.isEmpty {
            return faqs
        }
        return faqs.filter {
            $0.question.localizedCaseInsensitiveContains(searchText) ||
            $0.answer.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        List {
            Section(header: Text("Frequently Asked Questions")) {
                ForEach(filteredFAQs) { faq in
                    DisclosureGroup {
                        Text(faq.answer)
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding(.vertical, 8)
                    } label: {
                        Text(faq.question)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
            }
            
            /*Section(header: Text("Contact Support")) {
                Button(action: { /* TODO: Open email */ }) {
                    Label("Email Support", systemImage: "envelope")
                }
                
                Button(action: { /* TODO: Open website */ }) {
                    Label("Visit Website", systemImage: "globe")
                }
                
                Button(action: { /* TODO: Open feedback form */ }) {
                    Label("Send Feedback", systemImage: "bubble.left")
                }
            }*/
        }
        .searchable(text: $searchText, prompt: "Search help topics")
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FAQ: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}
