//
//  AnalyticsView.swift
//  SmartShopping
//
//  Created by user279038 on 12/1/25.
//


import SwiftUI
import Charts

struct AnalyticsView: View {
    @EnvironmentObject var listsViewModel: ListsViewModel
    @State private var selectedTimeFrame: TimeFrame = .month
    @State private var isLoading = false
    
    enum TimeFrame: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case quarter = "Quarter"
        case year = "Year"
    }
    
    var allItems: [ShoppingItem] {
        listsViewModel.lists.flatMap { $0.items ?? [] }
    }
    
    var purchasedItems: [ShoppingItem] {
        allItems.filter { $0.isPurchased }
    }
    
    var spendingByCategory: [(category: String, amount: Double)] {
        let grouped = Dictionary(grouping: purchasedItems) { $0.category ?? "Uncategorized" }
        return grouped.map { key, items in
            let total = items.reduce(0) { $0 + ($1.actualPrice ?? $1.estimatedPrice ?? 0) * Double($1.quantity) }
            return (key, total)
        }
        .sorted { $0.amount > $1.amount }
    }
    
    var monthlySpending: [(month: String, amount: Double)] {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM" // Use "MMM" for short month names
        
        var spending: [String: Double] = [:]
        
        for item in purchasedItems {
            let month = dateFormatter.string(from: item.updatedAt)
            let amount = (item.actualPrice ?? item.estimatedPrice ?? 0) * Double(item.quantity)
            spending[month, default: 0] += amount
        }
        
        // Sort by month order
        let monthOrder = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                         "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        
        return spending.map { (month: $0.key, amount: $0.value) }
            .sorted {
                guard let index1 = monthOrder.firstIndex(of: $0.month),
                      let index2 = monthOrder.firstIndex(of: $1.month) else {
                    return $0.month < $1.month
                }
                return index1 < index2
            }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Summary Cards
                    summaryCards
                    
                    // Spending by Category Chart
                    if !spendingByCategory.isEmpty {
                        categorySpendingChart
                    }
                    
                    // Monthly Spending Chart
                    if !monthlySpending.isEmpty {
                        monthlySpendingChart
                    }
                    
                    // List Stats
                    listStatsView
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Time Frame", selection: $selectedTimeFrame) {
                            ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                                Text(timeFrame.rawValue).tag(timeFrame)
                            }
                        }
                    } label: {
                        Image(systemName: "calendar")
                            .font(.title2)
                    }
                }
            }
            .refreshable {
                await listsViewModel.refresh()
            }
            .overlay {
                if isLoading {
                    ProgressView("Loading analytics...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
                }
            }
        }
    }
    
    private var summaryCards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                AnalyticsCard(
                    title: "Total Spent",
                    value: String(format: "$%.2f", totalSpent),
                    icon: "dollarsign.circle.fill",
                    color: .green
                )
                
                AnalyticsCard(
                    title: "Lists Created",
                    value: "\(listsViewModel.lists.count)",
                    icon: "list.bullet",
                    color: .blue
                )
                
                AnalyticsCard(
                    title: "Items Purchased",
                    value: "\(purchasedItems.count)",
                    icon: "cart.fill",
                    color: .orange
                )
                
                AnalyticsCard(
                    title: "Completion Rate",
                    value: String(format: "%.0f%%", completionRate),
                    icon: "checkmark.circle.fill",
                    color: .purple
                )
            }
            .padding(.horizontal, 5)
        }
    }
    
    private var categorySpendingChart: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Spending by Category")
                .font(.headline)
                .foregroundColor(.primary)
            
            Chart {
                ForEach(spendingByCategory, id: \.category) { data in
                    SectorMark(
                        angle: .value("Amount", data.amount),
                        innerRadius: .ratio(0.6),
                        angularInset: 1
                    )
                    .foregroundStyle(by: .value("Category", data.category))
                    .annotation(position: .overlay) {
                        if data.amount > 0 {
                            Text(String(format: "$%.0f", data.amount))
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .frame(height: 250)
            .chartLegend(position: .bottom, alignment: .center, spacing: 10)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.1), radius: 2)
    }
    
    private var monthlySpendingChart: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Monthly Spending")
                .font(.headline)
                .foregroundColor(.primary)
            
            Chart {
                ForEach(monthlySpending, id: \.month) { data in
                    BarMark(
                        x: .value("Month", data.month),
                        y: .value("Amount", data.amount)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .blue.opacity(0.7)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    RuleMark(y: .value("Average", averageMonthlySpending))
                        .foregroundStyle(.orange)
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.1), radius: 2)
    }
    
    private var listStatsView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("List Statistics")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                StatBox(title: "Active Lists",
                       value: "\(listsViewModel.lists.filter { !$0.isCompleted }.count)",
                       color: .blue)
                
                StatBox(title: "Completed Lists",
                       value: "\(listsViewModel.lists.filter { $0.isCompleted }.count)",
                       color: .green)
                
                StatBox(title: "Avg Items/List",
                       value: String(format: "%.1f", averageItemsPerList),
                       color: .orange)
                
                StatBox(title: "Avg List Cost",
                       value: String(format: "$%.2f", averageListCost),
                       color: .purple)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.1), radius: 2)
    }
    
    // Computed properties
    private var totalSpent: Double {
        purchasedItems.reduce(0) { $0 + ($1.actualPrice ?? $1.estimatedPrice ?? 0) * Double($1.quantity) }
    }
    
    private var completionRate: Double {
        guard !listsViewModel.lists.isEmpty else { return 0 }
        let completed = listsViewModel.lists.filter { $0.isCompleted }.count
        return (Double(completed) / Double(listsViewModel.lists.count)) * 100
    }
    
    private var averageMonthlySpending: Double {
        guard !monthlySpending.isEmpty else { return 0 }
        return monthlySpending.reduce(0) { $0 + $1.amount } / Double(monthlySpending.count)
    }
    
    private var averageItemsPerList: Double {
        guard !listsViewModel.lists.isEmpty else { return 0 }
        let totalItems = listsViewModel.lists.reduce(0) { $0 + ($1.items.count ?? 0) }
        return Double(totalItems) / Double(listsViewModel.lists.count)
    }
    
    private var averageListCost: Double {
        guard !listsViewModel.lists.isEmpty else { return 0 }
        let totalCost = listsViewModel.lists.reduce(0) { $0 + $1.totalSpent }
        return totalCost / Double(listsViewModel.lists.count)
    }
}

struct AnalyticsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 150, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.headline)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.1), radius: 2)
    }
}
