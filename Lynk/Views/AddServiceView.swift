//
//  AddServiceView.swift
//  Lynk
//
//  Created by gülçin çetin on 9.02.2026.
//

import SwiftUI
import SwiftData

struct AddServiceView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var vehicle: Vehicle
    
    @State private var title = ""
    @State private var priceString = ""
    @State private var notes = ""
    @State private var date = Date()
    
    // Quick Presets for Detailers (Speed is key!)
    let commonServices = [
        ("Maintenance Wash", "50"),
        ("Interior Detail", "150"),
        ("Ext. Polish & Wax", "200"),
        ("Ceramic Coating", "800")
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                // --- QUICK PRESETS ---
                Section(header: Text("Quick Select")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(commonServices, id: \.0) { service in
                                Button(action: {
                                    title = service.0
                                    priceString = service.1
                                }) {
                                    VStack {
                                        Text(service.0)
                                            .font(.caption)
                                            .bold()
                                        Text("$\(service.1)")
                                            .font(.caption2)
                                    }
                                    .padding(8)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets()) // Edge-to-edge scroll
                    .padding(.vertical, 10)
                }
                
                // --- MANUAL ENTRY ---
                Section(header: Text("Service Details")) {
                    TextField("Service Name", text: $title)
                    
                    HStack {
                        Text("$")
                        TextField("Price", text: $priceString)
                            .keyboardType(.decimalPad)
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section(header: Text("Technician Notes")) {
                    TextField("e.g. Used extra compound on hood...", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("New Service")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveService()
                        dismiss()
                    }
                    .disabled(title.isEmpty || priceString.isEmpty)
                }
            }
        }
    }
    
    func saveService() {
        guard let price = Double(priceString) else { return }
        
        let newService = Service(title: title, price: price, date: date)
        newService.notes = notes
        
        // Link to Vehicle
        newService.vehicle = vehicle
        
        modelContext.insert(newService)
    }
}
