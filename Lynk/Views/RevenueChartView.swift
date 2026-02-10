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
            Text("Income Source")
                .font(.headline)
                .padding(.leading)
            
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
            .chartForegroundStyleScale(range: [
                Color.lynkYellow,
                Color.blue,
                Color.green,
                Color.orange,
                Color.purple
            ])
        }
    }
}
