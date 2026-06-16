//
//  ClientDetailViewModel.swift
//  Lynk
//
//  Created by gülçin çetin on 2.02.2026.
//

import Foundation
import SwiftData

@Observable
class ClientDetailViewModel {
    var client: Client
    
    init(client: Client) {
        self.client = client
    }
    
    // Logic: Calculate total lifetime value from ALL vehicles
    var totalEarnings: Double {
        client.vehicles?.reduce(0) { total, vehicle in
            total + vehicle.totalRevenue
        } ?? 0.0
    }
    
    var formattedEarnings: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: totalEarnings)) ?? "$0.00"
    }
    
    func deleteVehicle(vehicle: Vehicle, context: ModelContext) {
        context.delete(vehicle)
    }
}
