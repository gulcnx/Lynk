//
//  DashboardView.swift
//  Lynk
//
//  Created by gülçin çetin on 9.02.2026.
//

import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @EnvironmentObject var store: StoreManager
    
    @Query private var clients: [Client]
    @Query(sort: \Service.date, order: .forward) private var recentServices: [Service]
    @Query private var expenses: [Expense]
    
    @AppStorage("monthlyGoal") private var monthlyGoal: Double = 5000.0
    @AppStorage("userName") private var userName: String = "User"
    
    @State private var showPaywall = false
    
    // --- COMPUTED PROPERTIES ---
    var activeJobsCount: Int { recentServices.filter { !$0.isPaid }.count }
    var pendingRevenue: Double { recentServices.filter { !$0.isPaid }.reduce(0) { $0 + $1.price } }
    var totalRevenue: Double { recentServices.filter { $0.isPaid }.reduce(0) { $0 + $1.price } }
    var totalExpenses: Double { expenses.reduce(0) { $0 + $1.amount } }
    var netProfit: Double { totalRevenue - totalExpenses }
    
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
                VStack(spacing: 24) {
                    
                    // --- HEADER ---
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(Date(), format: .dateTime.weekday().month().day())
                                .font(.caption)
                                .textCase(.uppercase)
                                .foregroundStyle(Color.lynkMint)
                                .tracking(1)
                            
                            Text("Welcome, \(userName)")
                                .font(.system(size: 28, weight: .bold))
                                .primaryText()
                        }
                        Spacer()
                        
                        // Net Profit Badge
                        VStack(alignment: .trailing) {
                            Text("NET PROFIT")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .secondaryText()
                            Text(netProfit, format: .currency(code: "USD"))
                                .font(.headline)
                                .foregroundStyle(netProfit >= 0 ? Color.lynkMint : Color.lynkRed)
                        }
                        .padding(10)
                        .luxuryCardStyle()
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // --- FREE TIER TRACKER ---
                    if !store.hasProAccess {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("FREE PLAN: \(clients.count) / 5 CLIENTS")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .secondaryText()
                                
                                // Progress bar
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Capsule().fill(Color.gray.opacity(0.3))
                                        Capsule().fill(clients.count >= 5 ? Color.orange : Color.lynkMint)
                                            .frame(width: geo.size.width * CGFloat(min(clients.count, 5)) / 5.0)
                                    }
                                }
                                .frame(height: 6)
                                .padding(.top, 4)
                            }
                            Spacer()
                            Button(action: { showPaywall = true }) {
                                Text("Upgrade")
                                    .font(.caption)
                                    .bold()
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(LinearGradient.lynkMintGradient)
                                    .foregroundStyle(.black)
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                        .luxuryCardStyle()
                        .padding(.horizontal)
                    }
                    
                    // --- STATS ROW ---
                    HStack(spacing: 15) {
                        StatCard(title: "Active Jobs", value: "\(activeJobsCount)", icon: "car.fill")
                        StatCard(title: "Pending", value: pendingRevenue.formatted(.currency(code: "USD")), icon: "hourglass")
                    }
                    .padding(.horizontal)

                    // --- GOAL BAR ---
                    GoalCard(current: currentMonthRevenue, target: monthlyGoal)
                        .padding(.horizontal)
                    
                    // --- REVENUE CHART ---
                    VStack(alignment: .leading, spacing: 15) {
                        Text("REVENUE SOURCE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .secondaryText()
                            .padding(.horizontal)
                        
                        ZStack {
                            RevenueChartView(clients: clients)
                                //  Blurs the chart if they aren't Pro!
                                .blur(radius: store.hasProAccess ? 0 : 8)
                                .allowsHitTesting(store.hasProAccess)
                            
                            //  The Lock Overlay
                            if !store.hasProAccess {
                                VStack(spacing: 12) {
                                    Image(systemName: "lock.fill")
                                        .font(.title)
                                        .foregroundStyle(Color.lynkMint)
                                    Text("Pro Analytics Locked")
                                        .font(.headline)
                                        .primaryText()
                                    Button("Unlock with Pro") {
                                        showPaywall = true
                                    }
                                    .font(.caption)
                                    .bold()
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(LinearGradient.lynkMintGradient)
                                    .foregroundStyle(.black)
                                    .cornerRadius(8)
                                }
                                .padding()
                                .background(Color.lynkCardDark.opacity(0.8))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // --- RECENT SERVICES ---
                    VStack(alignment: .leading, spacing: 15) {
                        Text("RECENT ACTIVITY")
                            .font(.caption)
                            .fontWeight(.bold)
                            .secondaryText()
                            .padding(.horizontal)
                        
                        if recentServices.isEmpty {
                            Text("No activity yet.")
                                .secondaryText()
                                .padding(.horizontal)
                        } else {
                            ForEach(recentServices.prefix(5)) { service in
                                if let vehicle = service.vehicle {
                                    NavigationLink(destination: VehicleDetailView(vehicle: vehicle)) {
                                        RecentActivityRow(service: service)
                                    }
                                } else {
                                    RecentActivityRow(service: service)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // --- FOOTER ---
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.title3)
                            .foregroundStyle(LinearGradient.lynkMintGradient)
                        Text("LYNK STUDIO")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .tracking(3)
                            .secondaryText()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                }
            }
            .premiumBackground()
            //  Presents the Paywall Sheet globally for the Dashboard
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}

// --- SUB-VIEWS ---

// Isolated Row UI for Recent Services
struct RecentActivityRow: View {
    let service: Service
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(service.title)
                    .font(.headline)
                    .primaryText()
                Text(service.vehicle?.make ?? "Unknown Vehicle")
                    .font(.caption)
                    .secondaryText()
            }
            Spacer()
            
            Text(service.price, format: .currency(code: "USD"))
                .font(.subheadline)
                .fontWeight(.bold)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    service.isPaid
                    ? Color.lynkMint.opacity(0.2)
                    : Color.orange.opacity(0.2)
                )
                .foregroundStyle(
                    service.isPaid ? Color.lynkMint : Color.orange
                )
                .cornerRadius(8)
        }
        .padding()
        .luxuryCardStyle()
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(LinearGradient.lynkMintGradient)
            
            VStack(alignment: .leading) {
                Text(value)
                    .font(.title2)
                    .bold()
                    .primaryText()
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                
                Text(title.uppercased())
                    .font(.caption2)
                    .fontWeight(.bold)
                    .secondaryText()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .luxuryCardStyle()
    }
}

struct GoalCard: View {
    let current: Double
    let target: Double
    
    var body: some View {
        let percent = target > 0 ? (current / target) : 0
        
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("MONTHLY GOAL")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .secondaryText()
                Spacer()
                Text("\(Int(percent * 100))%")
                    .font(.caption)
                    .bold()
                    .foregroundStyle(Color.lynkMint)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(LinearGradient.lynkMintGradient)
                        .frame(width: min(geo.size.width * percent, geo.size.width), height: 8)
                        .shadow(color: Color.lynkMint.opacity(0.5), radius: 5, x: 0, y: 0)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .luxuryCardStyle()
    }
}
