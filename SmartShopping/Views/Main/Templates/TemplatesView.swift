//
//  TemplatesView.swift
//  SmartShopping
//
//  Created by user279038 on 12/1/25.
//


import SwiftUI
import Supabase

struct TemplatesView: View {
    @EnvironmentObject var listsViewModel: ListsViewModel
    @State private var showingCreateTemplate = false
    @State private var searchText = ""
    @State private var selectedTemplate: ShoppingTemplate?
    @State private var userTemplates: [ShoppingTemplate] = []
    @State private var isLoading = true
    @State private var showingError = false
    @State private var errorMessage = ""
    
    // Hardcoded templates for demo
    private let hardcodedTemplates: [ShoppingTemplate] = [
        ShoppingTemplate(
            userId: "demo_user",
            name: "Weekly Groceries",
            description: "Essential groceries for the week",
            category: "Groceries",
            items: [
                TemplateItem(name: "Milk", category: "Dairy", quantity: 1, estimatedPrice: 3.99),
                TemplateItem(name: "Bread", category: "Bakery", quantity: 2, estimatedPrice: 4.50),
                TemplateItem(name: "Eggs", category: "Dairy", quantity: 12, estimatedPrice: 5.99),
                TemplateItem(name: "Chicken Breast", category: "Meat", quantity: 1, estimatedPrice: 8.99),
                TemplateItem(name: "Bananas", category: "Produce", quantity: 6, estimatedPrice: 2.49),
                TemplateItem(name: "Rice", category: "Pantry", quantity: 1, estimatedPrice: 6.99)
            ]
        ),
        ShoppingTemplate(
            userId: "demo_user",
            name: "Office Supplies",
            description: "Basic office stationery",
            category: "Office",
            items: [
                TemplateItem(name: "Notebooks", category: "Stationery", quantity: 3, estimatedPrice: 12.99),
                TemplateItem(name: "Pens", category: "Stationery", quantity: 10, estimatedPrice: 8.99),
                TemplateItem(name: "Sticky Notes", category: "Stationery", quantity: 2, estimatedPrice: 4.99),
                TemplateItem(name: "Paper Clips", category: "Office", quantity: 1, estimatedPrice: 2.49),
                TemplateItem(name: "Highlighters", category: "Stationery", quantity: 4, estimatedPrice: 5.99)
            ]
        ),
        ShoppingTemplate(
            userId: "demo_user",
            name: "Cleaning Supplies",
            description: "Household cleaning essentials",
            category: "Home",
            items: [
                TemplateItem(name: "Laundry Detergent", category: "Cleaning", quantity: 1, estimatedPrice: 14.99),
                TemplateItem(name: "Dish Soap", category: "Cleaning", quantity: 1, estimatedPrice: 3.99),
                TemplateItem(name: "Paper Towels", category: "Cleaning", quantity: 2, estimatedPrice: 8.99),
                TemplateItem(name: "All-Purpose Cleaner", category: "Cleaning", quantity: 1, estimatedPrice: 5.99),
                TemplateItem(name: "Trash Bags", category: "Cleaning", quantity: 1, estimatedPrice: 9.99),
                TemplateItem(name: "Glass Cleaner", category: "Cleaning", quantity: 1, estimatedPrice: 4.49)
            ]
        ),
        ShoppingTemplate(
            userId: "demo_user",
            name: "BBQ Party",
            description: "Everything for a backyard BBQ",
            category: "Entertainment",
            items: [
                TemplateItem(name: "Hamburger Patties", category: "Meat", quantity: 12, estimatedPrice: 19.99),
                TemplateItem(name: "Hot Dogs", category: "Meat", quantity: 16, estimatedPrice: 12.99),
                TemplateItem(name: "Hamburger Buns", category: "Bakery", quantity: 2, estimatedPrice: 5.99),
                TemplateItem(name: "Hot Dog Buns", category: "Bakery", quantity: 2, estimatedPrice: 4.99),
                TemplateItem(name: "Ketchup", category: "Condiments", quantity: 1, estimatedPrice: 3.99),
                TemplateItem(name: "Mustard", category: "Condiments", quantity: 1, estimatedPrice: 2.99),
                TemplateItem(name: "Charcoal", category: "BBQ", quantity: 1, estimatedPrice: 14.99),
                TemplateItem(name: "Paper Plates", category: "Disposable", quantity: 2, estimatedPrice: 7.99),
                TemplateItem(name: "Plastic Cups", category: "Disposable", quantity: 1, estimatedPrice: 5.99)
            ]
        ),
        ShoppingTemplate(
            userId: "demo_user",
            name: "School Supplies",
            description: "Back to school essentials",
            category: "Education",
            items: [
                TemplateItem(name: "Backpack", category: "School", quantity: 1, estimatedPrice: 29.99),
                TemplateItem(name: "Pencils", category: "Stationery", quantity: 24, estimatedPrice: 6.99),
                TemplateItem(name: "Pens", category: "Stationery", quantity: 12, estimatedPrice: 8.99),
                TemplateItem(name: "Binders", category: "School", quantity: 3, estimatedPrice: 15.99),
                TemplateItem(name: "Notebooks", category: "Stationery", quantity: 5, estimatedPrice: 12.99),
                TemplateItem(name: "Calculator", category: "School", quantity: 1, estimatedPrice: 19.99),
                TemplateItem(name: "Notebook Paper", category: "Stationery", quantity: 2, estimatedPrice: 8.99),
                TemplateItem(name: "Ruler", category: "Stationery", quantity: 1, estimatedPrice: 1.99)
            ]
        ),
        ShoppingTemplate(
            userId: "demo_user",
            name: "Gym Essentials",
            description: "Fitness and workout supplies",
            category: "Fitness",
            items: [
                TemplateItem(name: "Protein Powder", category: "Nutrition", quantity: 1, estimatedPrice: 24.99),
                TemplateItem(name: "Workout Towel", category: "Fitness", quantity: 2, estimatedPrice: 12.99),
                TemplateItem(name: "Water Bottle", category: "Fitness", quantity: 1, estimatedPrice: 14.99),
                TemplateItem(name: "Resistance Bands", category: "Fitness", quantity: 1, estimatedPrice: 19.99),
                TemplateItem(name: "Workout Gloves", category: "Fitness", quantity: 1, estimatedPrice: 16.99)
            ]
        ),
        ShoppingTemplate(
            userId: "demo_user",
            name: "Pets Supplies",
            description: "Pet care essentials",
            category: "Pets",
            items: [
                TemplateItem(name: "Dog Food", category: "Pet Food", quantity: 1, estimatedPrice: 34.99),
                TemplateItem(name: "Cat Food", category: "Pet Food", quantity: 1, estimatedPrice: 24.99),
                TemplateItem(name: "Pet Treats", category: "Pet Food", quantity: 2, estimatedPrice: 12.99),
                TemplateItem(name: "Cat Litter", category: "Pet Care", quantity: 1, estimatedPrice: 18.99),
                TemplateItem(name: "Pet Toys", category: "Pet Accessories", quantity: 3, estimatedPrice: 15.99)
            ]
        ),
        ShoppingTemplate(
            userId: "demo_user",
            name: "Baby Essentials",
            description: "New baby shopping list",
            category: "Family",
            items: [
                TemplateItem(name: "Diapers", category: "Baby Care", quantity: 1, estimatedPrice: 29.99),
                TemplateItem(name: "Baby Wipes", category: "Baby Care", quantity: 3, estimatedPrice: 14.99),
                TemplateItem(name: "Baby Formula", category: "Nutrition", quantity: 2, estimatedPrice: 34.99),
                TemplateItem(name: "Baby Shampoo", category: "Baby Care", quantity: 1, estimatedPrice: 8.99),
                TemplateItem(name: "Onesies", category: "Clothing", quantity: 5, estimatedPrice: 24.99)
            ]
        ),
        ShoppingTemplate(
            userId: "demo_user",
            name: "Holiday Baking",
            description: "Ingredients for holiday cookies and treats",
            category: "Food & Drinks",
            items: [
                TemplateItem(name: "Flour", category: "Baking", quantity: 1, estimatedPrice: 4.99),
                TemplateItem(name: "Sugar", category: "Baking", quantity: 2, estimatedPrice: 6.99),
                TemplateItem(name: "Butter", category: "Dairy", quantity: 4, estimatedPrice: 15.96),
                TemplateItem(name: "Eggs", category: "Dairy", quantity: 12, estimatedPrice: 5.99),
                TemplateItem(name: "Vanilla Extract", category: "Baking", quantity: 1, estimatedPrice: 8.99),
                TemplateItem(name: "Chocolate Chips", category: "Baking", quantity: 2, estimatedPrice: 7.98),
                TemplateItem(name: "Sprinkles", category: "Baking", quantity: 3, estimatedPrice: 8.97)
            ]
        ),
        ShoppingTemplate(
            userId: "demo_user",
            name: "Camping Trip",
            description: "Outdoor camping essentials",
            category: "Outdoors",
            items: [
                TemplateItem(name: "Tent", category: "Camping", quantity: 1, estimatedPrice: 89.99),
                TemplateItem(name: "Sleeping Bags", category: "Camping", quantity: 2, estimatedPrice: 79.98),
                TemplateItem(name: "Flashlight", category: "Camping", quantity: 2, estimatedPrice: 19.98),
                TemplateItem(name: "First Aid Kit", category: "Safety", quantity: 1, estimatedPrice: 24.99),
                TemplateItem(name: "Insect Repellent", category: "Camping", quantity: 2, estimatedPrice: 13.98),
                TemplateItem(name: "Cooler", category: "Camping", quantity: 1, estimatedPrice: 39.99)
            ]
        ),
        ShoppingTemplate(
            userId: "demo_user",
            name: "Home Improvement",
            description: "Basic home repair tools and supplies",
            category: "Home",
            items: [
                TemplateItem(name: "Hammer", category: "Tools", quantity: 1, estimatedPrice: 12.99),
                TemplateItem(name: "Screwdriver Set", category: "Tools", quantity: 1, estimatedPrice: 19.99),
                TemplateItem(name: "Measuring Tape", category: "Tools", quantity: 1, estimatedPrice: 9.99),
                TemplateItem(name: "Duct Tape", category: "Tools", quantity: 2, estimatedPrice: 11.98),
                TemplateItem(name: "Paint Brushes", category: "Tools", quantity: 3, estimatedPrice: 14.97),
                TemplateItem(name: "Sandpaper", category: "Tools", quantity: 5, estimatedPrice: 12.45)
            ]
        ),
        ShoppingTemplate(
            userId: "demo_user",
            name: "Healthy Breakfast",
            description: "Ingredients for a week of healthy breakfasts",
            category: "Food & Drinks",
            items: [
                TemplateItem(name: "Greek Yogurt", category: "Dairy", quantity: 4, estimatedPrice: 15.96),
                TemplateItem(name: "Granola", category: "Pantry", quantity: 1, estimatedPrice: 7.99),
                TemplateItem(name: "Berries", category: "Produce", quantity: 3, estimatedPrice: 14.97),
                TemplateItem(name: "Oatmeal", category: "Pantry", quantity: 1, estimatedPrice: 4.99),
                TemplateItem(name: "Almond Milk", category: "Beverages", quantity: 2, estimatedPrice: 7.98),
                TemplateItem(name: "Whole Wheat Bread", category: "Bakery", quantity: 1, estimatedPrice: 4.50)
            ]
        )
    ]
    // Combine hardcoded templates with user templates
    var allTemplates: [ShoppingTemplate] {
        return hardcodedTemplates + userTemplates
    }
    
    var filteredTemplates: [ShoppingTemplate] {
        if searchText.isEmpty {
            return allTemplates
        } else {
            let searchLower = searchText.lowercased()
            return allTemplates.filter { template in
                template.name.lowercased().contains(searchLower) ||
                (template.description?.lowercased().contains(searchLower) ?? false) ||
                template.category.lowercased().contains(searchLower)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    loadingView
                } else if filteredTemplates.isEmpty {
                    emptyStateView
                } else {
                    templatesListView
                }
            }
            .navigationTitle("Templates")
            .searchable(text: $searchText, prompt: "Search templates")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showingCreateTemplate = true } label: {
                        Image(systemName: "plus.circle.fill").font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingCreateTemplate) {
                CreateTemplateView(onTemplateCreated: fetchTemplates)
            }
            .sheet(item: $selectedTemplate) { template in
                UseTemplateView(template: template, listsViewModel: listsViewModel)
            }
            .onAppear {
                fetchTemplates()
            }
            .refreshable {
                fetchTemplates()
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading templates...")
                .foregroundColor(.secondary)
                .padding(.top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var templatesListView: some View {
        List {
            // User Templates Section
            if !userTemplates.isEmpty {
                Section(header: Text("My Templates")) {
                    ForEach(userTemplates.filter { template in
                        if searchText.isEmpty {
                            return true
                        }
                        let searchLower = searchText.lowercased()
                        return template.name.lowercased().contains(searchLower) ||
                               (template.description?.lowercased().contains(searchLower) ?? false) ||
                               template.category.lowercased().contains(searchLower)
                    }) { template in
                        templateRow(template)
                    }
                    .onDelete { indexSet in
                        deleteTemplate(at: indexSet)
                    }
                }
            }
            
            // Predefined Templates Section
            if !hardcodedTemplates.isEmpty {
                Section(header: Text("Predefined Templates")) {
                    ForEach(hardcodedTemplates.filter { template in
                        if searchText.isEmpty {
                            return true
                        }
                        let searchLower = searchText.lowercased()
                        return template.name.lowercased().contains(searchLower) ||
                               (template.description?.lowercased().contains(searchLower) ?? false) ||
                               template.category.lowercased().contains(searchLower)
                    }) { template in
                        templateRow(template)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    private func templateRow(_ template: ShoppingTemplate) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(template.name)
                            .font(.headline)
                        
                        Spacer()
                        
                        if template.isFavorite {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                        }
                        
                        Text("\(template.totalItems) items")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let description = template.description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label(template.category, systemImage: "tag")
                            .font(.caption2)
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        if template.timesUsed > 0 {
                            Text("Used \(template.timesUsed)×")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Spacer()
                
                Button("Use") {
                    selectedTemplate = template
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            
            // Show first 3 items as preview
            if let items = template.items, !items.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(items.prefix(3)) { item in
                        HStack {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 6, height: 6)
                            
                            Text(item.name)
                                .font(.caption)
                            
                            Spacer()
                            
                            if item.quantity > 1 {
                                Text("×\(item.quantity)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    if items.count > 3 {
                        Text("+ \(items.count - 3) more items")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.leading, 8)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .padding(.top, 50)
            
            Text("No templates found")
                .font(.headline)
            
            if searchText.isEmpty {
                Text("Create your first template to get started")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button {
                    showingCreateTemplate = true
                } label: {
                    Label("Create Template", systemImage: "plus.circle")
                }
                .buttonStyle(.borderedProminent)
            } else {
                Text("Try a different search")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Button("Clear Search") {
                    searchText = ""
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func fetchTemplates() {
        Task {
            do {
                isLoading = true
                
                guard let userId = listsViewModel.supabase.currentUserId else {
                    print("No user ID found")
                    userTemplates = []
                    await MainActor.run {
                        isLoading = false
                    }
                    return
                }
                
                print("Fetching templates for user: \(userId)")
                
                // Fetch user's templates from database
                let fetchedTemplates: [ShoppingTemplate] = try await listsViewModel.supabase.database
                    .from("shopping_templates")
                    .select()
                    .eq("user_id", value: userId)
                    .order("updated_at", ascending: false)
                    .execute()
                    .value
                
                print("Fetched \(fetchedTemplates.count) templates")
                
                await MainActor.run {
                    userTemplates = fetchedTemplates
                    isLoading = false
                }
                
            } catch {
                print("Error fetching templates: \(error)")
                
                await MainActor.run {
                    userTemplates = []
                    isLoading = false
                    errorMessage = "Failed to load templates: \(error.localizedDescription)"
                    showingError = true
                }
            }
        }
    }
    
    private func deleteTemplate(at indexSet: IndexSet) {
        Task {
            do {
                let templatesToDelete = indexSet.map { userTemplates[$0] }
                
                for template in templatesToDelete {
                    try await listsViewModel.supabase.database
                        .from("shopping_templates")
                        .delete()
                        .eq("id", value: template.id)
                        .execute()
                }
                
                // Refresh the list
                fetchTemplates()
                
            } catch {
                print("Error deleting template: \(error)")
                errorMessage = "Failed to delete template: \(error.localizedDescription)"
                showingError = true
            }
        }
    }
}



// MARK: - TemplateItem Model
struct TemplateItem: Identifiable, Codable {
    let id: String
    let name: String
    let category: String?
    let quantity: Int
    let estimatedPrice: Double?
    let notes: String?
    
    init(name: String, category: String? = nil, quantity: Int = 1, estimatedPrice: Double? = nil, notes: String? = nil) {
        self.id = UUID().uuidString
        self.name = name
        self.category = category
        self.quantity = quantity
        self.estimatedPrice = estimatedPrice
        self.notes = notes
    }
}

// MARK: - Preview
struct TemplatesView_Previews: PreviewProvider {
    static var previews: some View {
        TemplatesView()
            .environmentObject(ListsViewModel())
    }
}
