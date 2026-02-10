//
//  AddVehicleView.swift
//  Lynk
//
//  Created by gülçin çetin on 9.02.2026.
//

import SwiftUI
import SwiftData
import VisionKit

struct AddVehicleView: View {
    @State private var showScanner = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var client: Client
    
    @State private var make = ""
    @State private var model = ""
    @State private var yearString = ""
    @State private var color = ""
    @State private var plate = ""
    @State private var vin = ""
    
    var isValid: Bool {
        return !make.isEmpty && !model.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Vehicle Details")) {
                    HStack {
                        TextField("Make (e.g. BMW)", text: $make)
                        Divider()
                        TextField("Model (e.g. X5)", text: $model)
                    }
                    
                    HStack {
                        TextField("Year", text: $yearString)
                            .keyboardType(.numberPad)
                            .frame(width: 80)
                        Divider()
                        TextField("Color", text: $color)
                    }
                    
                    TextField("License Plate", text: $plate)
                        .autocapitalization(.allCharacters)
                }
                
                Section(header: Text("Identification")) {
                    HStack {
                        TextField("VIN (Chassis No)", text: $vin)
                            .textInputAutocapitalization(.characters)
                        
                        if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                            // REAL PHONE: Show Camera
                            Button(action: {
                                showScanner = true
                            }) {
                                Image(systemName: "camera.viewfinder")
                                    .font(.title2)
                                    .foregroundStyle(.blue)
                            }
                        } else {
                            // SIMULATOR: Debug Button
                            Button(action: {
                                vin = "WP0AB2A9XLS123456"
                            }) {
                                HStack {
                                    Text("Test")
                                        .font(.caption)
                                        .bold()
                                    Image(systemName: "magic.wand")
                                }
                                .foregroundStyle(.orange)
                                .padding(6)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(6)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showScanner) {
                VINScanner(scannedCode: $vin)
                    .presentationDetents([.medium, .large])
            }
            .navigationTitle("Add Vehicle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveVehicle()
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    func saveVehicle() {
        let yearInt = Int(yearString) ?? 2024
        let newVehicle = Vehicle(
            make: make,
            model: model,
            year: yearInt,
            color: color,
            plateNumber: plate
        )
        newVehicle.vin = vin
        newVehicle.client = client
        modelContext.insert(newVehicle)
    }
}
