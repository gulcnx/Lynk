//
//  AddProjectView.swift
//  Lynk
//
//  Created by gülçin çetin on 2.02.2026.
//

import SwiftUI
import SwiftData

struct AddProjectView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // We need the Client object passed in so we know who this project belongs to
    var client: Client
    
    @State private var viewModel = AddProjectViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Project Details")) {
                    TextField("Project Title (e.g. App Design)", text: $viewModel.title)
                    
                    TextField("Hourly Rate ($)", text: $viewModel.hourlyRateString)
                        .keyboardType(.decimalPad)
                    
                    TextField("Estimated Hours", text: $viewModel.hoursString)
                        .keyboardType(.decimalPad)
                    
                    DatePicker("Due Date", selection: $viewModel.dueDate, displayedComponents: .date)
                }
            }
            .navigationTitle("New Project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveProject(to: client, context: modelContext)
                        dismiss()
                    }
                    .disabled(!viewModel.isValid)
                }
            }
        }
    }
}
