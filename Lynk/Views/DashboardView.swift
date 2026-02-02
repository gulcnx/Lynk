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
    @Query(sort: \Project.dueDate, order: .forward) private var recentProjects: [Project]
    
    @AppStorage("monthlyGoal") private var monthlyGoal: Double = 5000.0
    
    @Environment(\.colorScheme) var colorScheme
    
    // --- COMPUTED PROPERTIES ---
    
    var activeJobsCount: Int {
        clients.flatMap { $0.projects ?? [] }.filter { !$0.isPaid }.count
    }
    
    var pendingRevenue: Double {
        clients.flatMap { $0.projects ?? [] }
            .filter { !$0.isPaid }
            .reduce(0) { $0 + $1.totalFee }
    }
    
    // Calculates income ONLY for the current month
    var currentMonthRevenue: Double {
        let now = Date()
        let calendar = Calendar.current
        let currentMonthProjects = clients.flatMap { $0.projects ?? [] }.filter { project in
            guard project.isPaid else { return false }
            return calendar.isDate(project.dueDate, equalTo: now, toGranularity: .month)
        }
        return currentMonthProjects.reduce(0) { $0 + $1.totalFee }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // --- 1. HEADER ---
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(Date(), format: .dateTime.weekday().month().day())
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                                .textCase(.uppercase)
                            
                            Text("Overview")
                                .font(.system(.largeTitle, design: .rounded))
                                .bold()
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // --- 2. MONTHLY GOAL CARD (NEW) ---
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Monthly Goal")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                            Spacer()
                            // Avoid division by zero
                            let percent = monthlyGoal > 0 ? Int((currentMonthRevenue / monthlyGoal) * 100) : 0
                            Text("\(percent)%")
                                .bold()
                                .foregroundStyle(Color.lynkYellow)
                        }
                        
                        // Progress Bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 12)
                                
                                Capsule()
                                    .fill(Color.lynkYellow)
                                    .frame(width: min(geo.size.width * (currentMonthRevenue / max(monthlyGoal, 1)), geo.size.width), height: 12)
                            }
                        }
                        .frame(height: 12)
                        
                        HStack {
                            Text(currentMonthRevenue, format: .currency(code: "USD"))
                                .font(.caption)
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                            Spacer()
                            Text(monthlyGoal, format: .currency(code: "USD"))
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                    }
                    .padding()
                    .background(colorScheme == .dark ? Color.lynkDarkGray : Color.white)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)

                    // --- 3. STATS CARDS ---
                    HStack(spacing: 15) {
                        StatCard(
                            title: "Active Jobs",
                            value: "\(activeJobsCount)",
                            icon: "briefcase.fill"
                        )
                        
                        StatCard(
                            title: "Pending",
                            value: pendingRevenue.formatted(.currency(code: "USD")),
                            icon: "hourglass"
                        )
                    }
                    .padding(.horizontal)

                    // --- 4. CHART ---
                    if !clients.isEmpty {
                        RevenueChartView(clients: clients)
                            .padding(.vertical)
                            .background(colorScheme == .dark ? Color.lynkDarkGray : Color.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                            .padding(.horizontal)
                    }
                    
                    // --- 5. UPCOMING DEADLINES ---
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Upcoming Deadlines")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if recentProjects.isEmpty {
                             Text("No active projects")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)
                        } else {
                            // Show next 3 projects
                            ForEach(recentProjects.prefix(3)) { project in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(project.title)
                                            .font(.system(.body, design: .rounded))
                                            .bold()
                                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                                        Text(project.client?.name ?? "Unknown")
                                            .font(.caption)
                                            .foregroundStyle(.gray)
                                    }
                                    Spacer()
                                    Text(project.dueDate, style: .date)
                                        .font(.caption)
                                        .padding(6)
                                        .background(Color.lynkYellow.opacity(0.2))
                                        .cornerRadius(6)
                                }
                                .padding()
                                .background(colorScheme == .dark ? Color.lynkDarkGray : Color.white)
                                .cornerRadius(12)
                                .padding(.horizontal)
                                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                            }
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.bottom, 20)
            }
            .premiumBackground() // Uses your Theme.swift logic
        }
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
