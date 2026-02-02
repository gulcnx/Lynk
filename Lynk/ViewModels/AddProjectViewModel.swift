//
//  AddProjectViewModel.swift
//  Lynk
//
//  Created by gülçin çetin on 2.02.2026.
//

import Foundation
import SwiftData

@Observable
class AddProjectViewModel {
    var title = ""
    var hourlyRateString = ""
    var hoursString = ""
    var dueDate = Date()
    
    var isValid: Bool {
        return !title.isEmpty && Double(hourlyRateString) != nil && Double(hoursString) != nil
    }
    
    func saveProject(to client: Client, context: ModelContext) {
        guard let rate = Double(hourlyRateString),
              let hours = Double(hoursString) else { return } // 👈 Unwrap hours
        
        let newProject = Project(title: title, hourlyRate: rate, dueDate: dueDate)
        newProject.hoursWorked = hours 
        newProject.client = client
        
        context.insert(newProject)
    }
}
