//
//  RevenueChartView.swift
//  Lynk
//
//  Created by gülçin çetin on 2.02.2026.
//

import SwiftUI
import SwiftData
import Charts

struct RevenueChartView: View {
    var clients: [Client]
    
    var body: some View {
        VStack(alignment: .leading) {
            // Calculate total revenue dynamically
            let totalRev = clients.reduce(0) { $0 + $1.totalLifetimeValue }
            
            if totalRev == 0 {
                // EMPTY STATE
                HStack {
                    Spacer()
                    VStack(spacing: 15) {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 10)
                            .frame(width: 120, height: 120)
                            .overlay(
                                Text("No Data")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            )
                        Text("Add paid services to see breakdown")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .frame(height: 200)
                .luxuryCardStyle() // Consistent styling
            } else {
                // ACTUAL CHART
                Chart {
                    ForEach(clients.sorted(by: { $0.totalLifetimeValue > $1.totalLifetimeValue }).prefix(5)) { client in
                        SectorMark(
                            angle: .value("Revenue", client.totalLifetimeValue),
                            innerRadius: .ratio(0.6),
                            angularInset: 2
                        )
                        .foregroundStyle(by: .value("Client", client.name))
                        .cornerRadius(5)
                    }
                }
                .frame(height: 200)
                .padding()
                .luxuryCardStyle() // Consistent styling
            }
        }
    }
}
