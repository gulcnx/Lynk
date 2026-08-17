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
    
    var totalEarnings: Double {
        client.vehicles?.reduce(0) { total, vehicle in
            total + vehicle.totalRevenue
        } ?? 0.0
    }
    
    func deleteVehicle(vehicle: Vehicle, context: ModelContext) {
        context.delete(vehicle)
    }
}
