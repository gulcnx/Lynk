//
//  AddClient-ViewModel.swift
//  Lynk
//
//  Created by gülçin çetin on 2.02.2026.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class AddClientViewModel {
    var name = ""
    var email = ""
    var phone = ""
    
    var isValid: Bool {
        return !name.isEmpty
    }

    func saveClient(context: ModelContext) {
        let newClient = Client(name: name, email: email, phoneNumber: phone)
        context.insert(newClient)
        
        do {
                try context.save()
                print("✅ Client Saved Successfully!")
            } catch {
                print("❌ Failed to save client: \(error)")
            }
    }
}
