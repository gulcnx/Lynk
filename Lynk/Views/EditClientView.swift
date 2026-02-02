//
//  EditClientView.swift
//  Lynk
//
//  Created by gülçin çetin on 2.02.2026.
//

import SwiftUI
import SwiftData

struct EditClientView: View {
    @Environment(\.dismiss) private var dismiss
    
    // We bind directly to the Client object so changes happen live
    @Bindable var client: Client
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Client Details")) {
                    TextField("Name", text: $client.name)
                    
                    TextField("Email", text: $client.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    
                    TextField("Phone", text: $client.phoneNumber)
                        .keyboardType(.phonePad)
                }
            }
            .navigationTitle("Edit Client")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
