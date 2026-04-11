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
    @State private var showPlateScanner = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var client: Client
    
    private let db = VehicleDataManager.shared
    
    // --- SMART PICKER STATES ---
    @State private var selectedMake = "Porsche"
    @State private var customMake = ""
    
    @State private var selectedModel = "911"
    @State private var customModel = ""
    
    @State private var selectedYear: String = String(Calendar.current.component(.year, from: Date()))
    @State private var customYear = ""
    
    @State private var selectedColor = "Black"
    @State private var customColor = ""
    
    @State private var plate = ""
    @State private var vin = ""
    
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
                        if let models = db.data.models[newValue], let first = models.first {
                            selectedModel = first
                        } else {
                            selectedModel = "Other..."
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
                    
                    // 3. YEAR PICKER (Now supports Custom)
                    Picker("Year", selection: $selectedYear) {
                        ForEach(db.years, id: \.self) { year in
                            Text(year).tag(year)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    if selectedYear == "Other..." {
                        TextField("Enter Custom Year (e.g. 1969)", text: $customYear)
                            .keyboardType(.numberPad) // Opens number keyboard
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
            .sheet(isPresented: $showScanner) {
                VINScanner(scannedCode: $vin)
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showPlateScanner) {
                PlateScanner(scannedCode: $plate)
                    .presentationDetents([.medium, .large])
            }
            .navigationTitle("Add Vehicle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.gray)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveVehicle()
                        dismiss()
                    }
                    .disabled(!isValid)
                    .foregroundStyle(isValid ? Color.lynkMint : .gray)
                }
            }
        }
    }
    
    func saveVehicle() {
        let newVehicle = Vehicle(
            make: finalMake,
            model: finalModel,
            year: finalYear,
            color: finalColor,
            plateNumber: plate
        )
        newVehicle.vin = vin
        newVehicle.client = client
        modelContext.insert(newVehicle)
    }
}

// MARK: THE SCANNER BRIDGE ❗️-

struct DataScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let controller = DataScannerViewController(
            recognizedDataTypes: [.text()], // We want text for VIN/Plates
            qualityLevel: .balanced,
            isHighlightingEnabled: true
        )
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        // Start scanning as soon as the view appears
        try? uiViewController.startScanning()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var parent: DataScannerView
        init(_ parent: DataScannerView) { self.parent = parent }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text):
                parent.scannedCode = text.transcript
                parent.dismiss() // Auto-close when a code is tapped
            default: break
            }
        }
    }
}
