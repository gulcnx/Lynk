//
//  DataModels.swift
//  Lynk
//
//  Created by gülçin çetin on 2.02.2026.
//

import Foundation
import SwiftData

// MARK: - EXPENSE
@Model
class Expense {
    var title: String = ""
    var amount: Double = 0.0
    var date: Date = Date()
    var category: String = "General"
    
    init(title: String, amount: Double, date: Date, category: String) {
        self.title = title
        self.amount = amount
        self.date = date
        self.category = category
    }
}

// MARK: - CLIENT
@Model
class Client {
    var name: String = ""
    var email: String = ""
    var phoneNumber: String = ""
    var dateCreated: Date = Date()
    
    @Relationship(deleteRule: .cascade) var vehicles: [Vehicle]? = []
    @Relationship(deleteRule: .cascade) var appointments: [Appointment]? = []
    
    init(name: String, email: String, phoneNumber: String) {
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
        self.dateCreated = Date()
        self.vehicles = []
    }
    
    var totalLifetimeValue: Double {
        guard let vehicles = vehicles else { return 0.0 }
        return vehicles.reduce(0.0) { total, vehicle in
            total + vehicle.totalRevenue
        }
    }
}

// MARK: - VEHICLE
@Model
class Vehicle {
    var make: String = ""       // e.g. "Porsche"
    var model: String = ""      // e.g. "911 GT3"
    var year: Int = 2024
    var vin: String? = ""       // Scanned from door jamb
    var color: String = ""      // e.g. "Shark Blue"
    var plateNumber: String = ""
    var notes: String = ""      // e.g. "Scratch on rear bumper"
    
    @Relationship(inverse: \Client.vehicles) var client: Client?
    
    @Relationship(deleteRule: .cascade) var services: [Service]? = []
    
    init(make: String, model: String, year: Int, color: String, plateNumber: String = "") {
        self.make = make
        self.model = model
        self.year = year
        self.color = color
        self.plateNumber = plateNumber
        self.services = []
    }
    
    var title: String {
        "\(year) \(make) \(model)"
    }
    
    var totalRevenue: Double {
        guard let services = services else { return 0.0 }
        return services.filter { $0.isPaid }.reduce(0) { $0 + $1.price }
    }
}

// MARK: - SERVICE
@Model
class Service {
    var title: String = ""          // e.g. "Ceramic Coating Package"
    var price: Double = 0.0         // Flat fee (Detailers rarely charge hourly)
    var date: Date = Date()
    var isPaid: Bool = false
    var notes: String = ""
    
    var vehicle: Vehicle?
    
    @Relationship(deleteRule: .cascade) var damagePoints: [DamagePoint]? = []
    @Relationship(deleteRule: .cascade) var inspectionPhotos: [InspectionPhoto]? = []
    
    init(title: String, price: Double, date: Date = Date()) {
        self.title = title
        self.price = price
        self.date = date
        self.isPaid = false
    }
}

@Model
class DamagePoint {
    var x: Double = 0.0
    var y: Double = 0.0
    var note: String = "" // e.g., "Scratch"
    
    @Relationship(inverse: \Service.damagePoints) var service: Service?
    
    init(x: Double, y: Double, note: String) {
        self.x = x
        self.y = y
        self.note = note
    }
}

@Model
class InspectionPhoto {
    @Attribute(.externalStorage) var photoData: Data?
    var date: Date = Date()
    var note: String = ""
    
    @Relationship(inverse: \Service.inspectionPhotos) var service: Service?
    
    init(photoData: Data, note: String) {
        self.photoData = photoData
        self.note = note
    }
}

// MARK: - APPOINTMENT
@Model
class Appointment {
    var title: String = ""
    var date: Date = Date()
    var notes: String = ""
    var isCompleted: Bool = false
    
    @Relationship(inverse: \Client.appointments) var client: Client?
    
    init(title: String, date: Date, notes: String = "") {
        self.title = title
        self.date = date
        self.notes = notes
    }
}

// MARK: CALENDAR MODELS
struct CalendarEvent: Identifiable {
    let id = UUID()
    let originalApptId: PersistentIdentifier?
    let vehicle: Vehicle?
    let title: String
    let date: Date
    let subtitle: String
    let isService: Bool
}

struct DateValue: Identifiable {
    var id = UUID().uuidString
    var date: Date
    var isCurrentMonth: Bool
}
