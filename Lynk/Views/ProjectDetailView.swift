//
//  ProjectDetailView.swift
//  Lynk
//
//  Created by gülçin çetin on 2.02.2026.
//

import SwiftUI
import SwiftData

struct ProjectDetailView: View {
    @Bindable var project: Project // @Bindable lets us edit it directly
    
    var body: some View {
        Form {
            Section(header: Text("Job Info")) {
                TextField("Title", text: $project.title)
                
                HStack {
                    Text("Hourly Rate")
                    Spacer()
                    TextField("Rate", value: $project.hourlyRate, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Hours Worked")
                    Spacer()
                    TextField("Hours", value: $project.hoursWorked, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                
                DatePicker("Due Date", selection: $project.dueDate, displayedComponents: .date)
            }
            
            Section(header: Text("Payment Status")) {
                Toggle(isOn: $project.isPaid) {
                    Label(
                        project.isPaid ? "Paid" : "Pending Payment",
                        systemImage: project.isPaid ? "checkmark.circle.fill" : "hourglass"
                    )
                    .foregroundStyle(project.isPaid ? .green : .orange)
                }
            }
            
            Section(header: Text("Financials")) {
                HStack {
                    Text("Total Fee")
                    Spacer()
                    Text(project.totalFee, format: .currency(code: "USD"))
                        .bold()
                        .foregroundStyle(project.isPaid ? .green : .primary)
                }
            }
            
            Section {
                Button(action: {
                    if let url = InvoiceGenerator.generateInvoice(for: project) {
                        sharePDF(url: url)
                    }
                }) {
                    Label("Export Invoice PDF", systemImage: "square.and.arrow.up")
                }
            }
        }
        .navigationTitle("Project Details")
    }
    
    func sharePDF(url: URL) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}
