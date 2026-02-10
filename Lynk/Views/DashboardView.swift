//
//  DashboardView.swift
//  Lynk
//
//  Created by gülçin çetin on 2.02.2026.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var clients: [Client]
    @Query(sort: \Service.date, order: .forward) private var recentServices: [Service] // CHANGED
    @Query private var expenses: [Expense]
    
    @AppStorage("monthlyGoal") private var monthlyGoal: Double = 5000.0
    @AppStorage("userName") private var userName: String = "User"
    
    @Environment(\.colorScheme) var colorScheme
    
    // --- COMPUTED PROPERTIES ---
    
    var activeJobsCount: Int {
        recentServices.filter { !$0.isPaid }.count
    }
    
    var pendingRevenue: Double {
        recentServices.filter { !$0.isPaid }.reduce(0) { $0 + $1.price }
    }
    
    var totalRevenue: Double {
        recentServices.filter { $0.isPaid }.reduce(0) { $0 + $1.price }
    }
    
    var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    var netProfit: Double {
        totalRevenue - totalExpenses
    }
    
    var currentMonthRevenue: Double {
        let now = Date()
        let calendar = Calendar.current
        let currentMonthServices = recentServices.filter { service in
            guard service.isPaid else { return false }
            return calendar.isDate(service.date, equalTo: now, toGranularity: .month)
        }
        return currentMonthServices.reduce(0) { $0 + $1.price }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // --- HEADER ---
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(Date(), format: .dateTime.weekday().month().day())
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                                .textCase(.uppercase)
                            
                            Text("Hello, \(userName)")
                                .font(.system(.largeTitle, design: .rounded))
                                .bold()
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                        }
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Net Profit")
                                .font(.caption)
                                .foregroundStyle(.gray)
                            Text(netProfit, format: .currency(code: "USD"))
                                .font(.headline)
                                .foregroundStyle(netProfit >= 0 ? .green : .red)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // --- MONTHLY GOAL ---
                    GoalCard(current: currentMonthRevenue, target: monthlyGoal)
                        .padding(.horizontal)

                    // --- STATS ---
                    HStack(spacing: 15) {
                        StatCard(
                            title: "Active Jobs",
                            value: "\(activeJobsCount)",
                            icon: "car.fill"
                        )
                        
                        StatCard(
                            title: "Pending",
                            value: pendingRevenue.formatted(.currency(code: "USD")),
                            icon: "hourglass"
                        )
                    }
                    .padding(.horizontal)

                    // --- CHART SECTION ---
                    VStack(alignment: .leading, spacing: 10) {
                        if totalRevenue == 0 {
                            VStack(spacing: 15) {
                                Image(systemName: "chart.bar.xaxis")
                                    .font(.largeTitle)
                                    .foregroundStyle(.gray)
                                Text("No Income Yet")
                                    .font(.headline)
                                Text("Mark a service as 'Paid' to see your stats.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .background(colorScheme == .dark ? Color.lynkDarkGray : Color.white)
                            .cornerRadius(16)
                            .padding(.horizontal)
                            
                        } else {
                            VStack(alignment: .leading) {
                                RevenueChartView(clients: clients)
                            }
                            .background(colorScheme == .dark ? Color.lynkDarkGray : Color.white)
                            .cornerRadius(16)
                            .padding(.horizontal)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                    }

                    // --- RECENT SERVICES ---
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Recent Services")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if recentServices.isEmpty {
                             Text("No active jobs")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)
                        } else {
                            ForEach(recentServices.prefix(3)) { service in
                                NavigationLink(destination: PhotoInspectionView(service: service)) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(service.title)
                                                .font(.body)
                                                .bold()
                                                .foregroundStyle(.primary)
                                            
                                            Text(service.vehicle?.make ?? "Unknown Car")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        
                                        Text(service.price, format: .currency(code: "USD"))
                                            .font(.caption)
                                            .padding(6)
                                            .background(service.isPaid ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                                            .cornerRadius(6)
                                            .foregroundStyle(service.isPaid ? .green : .orange)
                                        
                                        Image(systemName: "arrow.right")
                                            .font(.caption)
                                            .bold()
                                            .foregroundStyle(.primary)
                                    }
                                    .padding()
                                    .background(colorScheme == .dark ? Color.lynkDarkGray : Color.white)
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                                }
                            }
                        }
                    }
                    Spacer(minLength: 40)
                }
            }
            .premiumBackground()
        }
    }
}

// --- SUB-VIEW: GOAL CARD WITH LOGIC ---
struct GoalCard: View {
    let current: Double
    let target: Double
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let percent = target > 0 ? (current / target) : 0
        let isGoalReached = percent >= 1.0
        
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Monthly Goal")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                Spacer()
                
                if isGoalReached {
                    Text("🎉 COMPLETED")
                        .font(.caption)
                        .bold()
                        .padding(4)
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .cornerRadius(4)
                } else {
                    Text("\(Int(percent * 100))%")
                        .bold()
                        .foregroundStyle(Color.lynkYellow)
                }
            }
            
            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 12)
                    
                    Capsule()
                        .fill(isGoalReached ? Color.green : Color.lynkYellow)
                        .frame(width: min(geo.size.width * percent, geo.size.width), height: 12)
                }
            }
            .frame(height: 12)
            
            HStack {
                Text(current, format: .currency(code: "USD"))
                    .font(.caption)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                Spacer()
                Text(target, format: .currency(code: "USD"))
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color.lynkDarkGray : Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// --- STAT CARD ---
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.lynkYellow)
            
            VStack(alignment: .leading) {
                Text(value)
                    .font(.system(.title2, design: .rounded))
                    .bold()
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(colorScheme == .dark ? Color.lynkDarkGray : Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
