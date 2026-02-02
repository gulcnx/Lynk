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
    // The ViewModel "holds" the client it is showing
    var client: Client
    
    // We pass the client in when we initialize the VM
    init(client: Client) {
        self.client = client
    }
    
    // Business Logic: Calculate total earnings from this client
    var totalEarnings: Double {
        // Handle the optional relationship safely
        guard let projects = client.projects else { return 0.0 }
        
        let paidProjects = projects.filter { $0.isPaid }
        
        // Sum up the totalFee of ONLY the paid projects
        return paidProjects.reduce(0) { total, project in
            total + project.totalFee
        }
    }
    
    // Formatting currency (e.g., "$500.00" or "₺500,00")
    var formattedEarnings: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD" // You can change to USD or EUR
        return formatter.string(from: NSNumber(value: totalEarnings)) ?? "$0.00"
    }
    
    func togglePaymentStatus(for project: Project) {
        project.isPaid.toggle() // Flips false -> true
        // SwiftData autosaves this change!
    }
    
    // Logic: Delete a project
    func deleteProject(project: Project, context: ModelContext) {
        // 1. Remove from the client's list
        // (SwiftData handles the database delete automatically via the relationship rules,
        // but it's good practice to be explicit with the context)
        context.delete(project)
    }
}
