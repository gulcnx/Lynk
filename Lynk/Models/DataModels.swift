//
//  DataModels.swift
//  Lynk
//
//  Created by gülçin çetin on 2.02.2026.
//

import SwiftData
import Foundation

@Model
class Client {
    var name: String = ""
    var email: String = ""
    var phoneNumber: String = ""
    var dateCreated: Date = Date()
    
    // Relationship: One Client has many Projects
    // ".cascade" means if you delete the Client, their Projects get deleted too.
    @Relationship(deleteRule: .cascade) var projects: [Project]?
    
    init(name: String, email: String, phoneNumber: String) {
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
        self.dateCreated = Date()
        self.projects = []
    }
    var totalRevenue: Double {
            let paidProjects = projects?.filter { $0.isPaid } ?? []
            return paidProjects.reduce(0) { total, project in
                total + project.totalFee
            }
        }
        
    // Optional: You might want to see "Pending" money too
    var pendingRevenue: Double {
        let pendingProjects = projects?.filter { !$0.isPaid } ?? []
        return pendingProjects.reduce(0) { total, project in
            total + project.totalFee
        }
    }
}

@Model
class Project {
    var title: String = ""
    var hourlyRate: Double = 0.0
    var hoursWorked: Double = 0.0
    var isPaid: Bool = false
    var dueDate: Date = Date()
    
    // Relationship: Every Project belongs to one Client
    var client: Client?
    
    init(title: String, hourlyRate: Double, dueDate: Date) {
        self.title = title
        self.hourlyRate = hourlyRate
        self.hoursWorked = 0.0
        self.isPaid = false
        self.dueDate = dueDate
    }
    
    // A computed property (Business Logic)
    var totalFee: Double {
        return hourlyRate * hoursWorked
    }
}
