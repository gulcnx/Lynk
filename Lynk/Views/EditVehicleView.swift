//
//  EditVehicleView.swift
//  Lynk
//
//  Created by gülçin çetin on 18.02.2026.
//

import SwiftUI
import SwiftData
import VisionKit

struct EditVehicleView: View {
    @Bindable var vehicle: Vehicle
    @Environment(\.dismiss) private var dismiss
    
    // Pull from our JSON Manager
    private let db = VehicleDataManager.shared
    
    // --- STATES ---
    @State private var selectedMake = ""
    @State private var customMake = ""
    
    @State private var selectedModel = ""
    @State private var customModel = ""
    
    @State private var selectedYear = ""
    @State private var customYear = ""
    
    @State private var selectedColor = ""
    @State private var customColor = ""
    
    @State private var plate = ""
    @State private var vin = ""
    
    @State private var showScanner = false
    @State private var showPlateScanner = false
    
    // --- COMPUTED FINAL VALUES ---
    var finalMake: String { selectedMake == "Other..." ? customMake : selectedMake }
    var finalModel: String { (selectedMake == "Other..." || selectedModel == "Other...") ? customModel : selectedModel }
    var finalColor: String { selectedColor == "Custom..." ? customColor : selectedColor }
    
    var finalYear: Int {
        let yearString = selectedYear == "Other..." ? customYear : selectedYear
        return Int(yearString) ?? Calendar.current.component(.year, from: Date())
    }
    
    var isValid: Bool {
        return !finalMake.isEmpty && !finalModel.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // --- VEHICLE DETAILS ---
                Section(header: Text("Vehicle Details").foregroundStyle(Color.lynkMint)) {
                    
                    // 1. MAKE PICKER
                    Picker("Make", selection: $selectedMake) {
                        ForEach(db.data.makes, id: \.self) { make in
                            Text(make).tag(make)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: selectedMake) { oldValue, newValue in
                        if newValue != "Other..." {
                            if let models = db.data.models[newValue], let first = models.first {
                                selectedModel = first
                            } else {
                                selectedModel = "Other..."
                            }
                        }
                    }
                    
                    if selectedMake == "Other..." {
                        TextField("Enter Custom Make", text: $customMake)
                    }
                    
                    // 2. MODEL PICKER
                    if selectedMake != "Other..." {
                        Picker("Model", selection: $selectedModel) {
                            let availableModels = db.data.models[selectedMake] ?? ["Other..."]
                            ForEach(availableModels, id: \.self) { model in
                                Text(model).tag(model)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    if selectedMake == "Other..." || selectedModel == "Other..." {
                        TextField("Enter Custom Model", text: $customModel)
                    }
                    
                    // 3. YEAR PICKER
                    Picker("Year", selection: $selectedYear) {
                        ForEach(db.years, id: \.self) { year in
                            Text(year).tag(year)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    if selectedYear == "Other..." {
                        TextField("Enter Custom Year", text: $customYear)
                            .keyboardType(.numberPad)
                    }
                    
                    // 4. COLOR PICKER
                    Picker("Color", selection: $selectedColor) {
                        ForEach(db.data.colors, id: \.self) { color in
                            Text(color).tag(color)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    if selectedColor == "Custom..." {
                        TextField("Enter Custom Color", text: $customColor)
                    }
                    
                    // 5. PLATE
                    HStack {
                        TextField("License Plate", text: $plate)
                            .autocapitalization(.allCharacters)
                        
                        if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                            Button(action: { showPlateScanner = true }) {
                                Image(systemName: "camera.viewfinder")
                                    .font(.title2)
                                    .foregroundStyle(Color.lynkMint)
                            }
                        } else {
                            Button(action: { plate = "LXY1234" }) {
                                HStack {
                                    Text("Test")
                                        .font(.caption)
                                        .bold()
                                    Image(systemName: "magic.wand")
                                }
                                .foregroundStyle(Color.lynkMint)
                                .padding(6)
                                .background(Color.lynkMint.opacity(0.1))
                                .cornerRadius(6)
                            }
                        }
                    }
                }
                
                // --- IDENTIFICATION ---
                Section(header: Text("Identification").foregroundStyle(Color.lynkMint)) {
                    HStack {
                        TextField("VIN (Chassis No)", text: $vin)
                            .textInputAutocapitalization(.characters)
                        
                        if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                            Button(action: { showScanner = true }) {
                                Image(systemName: "camera.viewfinder")
                                    .font(.title2)
                                    .foregroundStyle(Color.lynkMint)
                            }
                        } else {
                            Button(action: { vin = "WP0AB2A9XLS123456" }) {
                                HStack {
                                    Text("Test")
                                        .font(.caption)
                                        .bold()
                                    Image(systemName: "magic.wand")
                                }
                                .foregroundStyle(Color.lynkMint)
                                .padding(6)
                                .background(Color.lynkMint.opacity(0.1))
                                .cornerRadius(6)
                            }
                        }
                    }
                }
            }
            .onAppear(perform: setupInitialData) // 👈 Loads the current vehicle info when opened
            .sheet(isPresented: $showScanner) {
                VINScanner(scannedCode: $vin)
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showPlateScanner) {
                PlateScanner(scannedCode: $plate)
                    .presentationDetents([.medium, .large])
            }
            .navigationTitle("Edit Vehicle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.gray)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                        dismiss()
                    }
                    .disabled(!isValid)
                    .foregroundStyle(isValid ? Color.lynkMint : .gray)
                }
            }
        }
    }
    
    // --- HELPER FUNCTIONS ---
    // This function cleverly figures out if the car's current details are in your JSON, or if it was a "Custom" entry!
    func setupInitialData() {
        // Setup Make
        if db.data.makes.contains(vehicle.make) {
            selectedMake = vehicle.make
        } else {
            selectedMake = "Other..."
            customMake = vehicle.make
        }
        
        // Setup Model
        let availableModels = db.data.models[selectedMake] ?? []
        if availableModels.contains(vehicle.model) {
            selectedModel = vehicle.model
        } else {
            selectedModel = "Other..."
            customModel = vehicle.model
        }
        
        // Setup Year
        let yearStr = String(vehicle.year)
        if db.years.contains(yearStr) {
            selectedYear = yearStr
        } else {
            selectedYear = "Other..."
            customYear = yearStr
        }
        
        // Setup Color
        if db.data.colors.contains(vehicle.color) {
            selectedColor = vehicle.color
        } else {
            selectedColor = "Custom..."
            customColor = vehicle.color
        }
        
        plate = vehicle.plateNumber
        vin = vehicle.vin ?? ""
    }
    
    // Writes the new values back to SwiftData safely
    func saveChanges() {
        vehicle.make = finalMake
        vehicle.model = finalModel
        vehicle.year = finalYear
        vehicle.color = finalColor
        vehicle.plateNumber = plate
        vehicle.vin = vin
    }
}
