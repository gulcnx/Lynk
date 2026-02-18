//
//  VehicleDataManager.swift
//  Lynk
//
//  Created by gülçin çetin on 18.02.2026.
//

import Foundation

// Maps exactly to the JSON structure
struct VehicleDatabase: Codable {
    let makes: [String]
    let models: [String: [String]]
    let colors: [String]
}

class VehicleDataManager {
    // Singleton pattern for global access
    static let shared = VehicleDataManager()
    
    var data: VehicleDatabase
    
    // Dynamic Years as Strings (so we can add "Other...")
    var years: [String] {
        let currentYear = Calendar.current.component(.year, from: Date())
        var yearStrings = Array(1990...(currentYear + 1)).reversed().map { String($0) }
        yearStrings.append("Other...")
        return yearStrings
    }
    
    // Fallback data in case the JSON is missing
    private let fallbackData = VehicleDatabase(
        makes: ["BMW", "Mercedes-Benz", "Porsche", "Other..."],
        models: [
            "BMW": ["3 Series", "5 Series", "X5", "Other..."],
            "Mercedes-Benz": ["C-Class", "E-Class", "S-Class", "Other..."],
            "Porsche": ["911", "Cayenne", "Macan", "Other..."]
        ],
        colors: ["Black", "White", "Silver", "Gray", "Red", "Blue", "Custom..."]
    )
    
    private init() {
        // 👇 FIXED: Now looks for "Vehicles.json" exactly as you named it
        if let url = Bundle.main.url(forResource: "Vehicles", withExtension: "json"),
           let rawData = try? Data(contentsOf: url),
           let decodedData = try? JSONDecoder().decode(VehicleDatabase.self, from: rawData) {
            self.data = decodedData
        } else {
            print("⚠️ Failed to load Vehicles.json, using fallback data.")
            self.data = fallbackData
        }
    }
}
