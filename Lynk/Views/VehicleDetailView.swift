//
//  VehicleDetailView.swift
//  Lynk
//
//  Created by gülçin çetin on 9.02.2026.
//

import SwiftUI
import SwiftData

struct VehicleDetailView: View {
    @Bindable var vehicle: Vehicle
    @Environment(\.modelContext) var modelContext
    @State private var showAddServiceSheet = false
    @State private var showEditVehicleSheet = false
    
    var body: some View {
        List {
            // --- CAR HEADER ---
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "car.side.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.blue)
                        
                        VStack(alignment: .leading) {
                            Text("\(vehicle.year) \(vehicle.make)")
                                .font(.title2)
                                .bold()
                            Text(vehicle.model)
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    HStack(spacing: 20) {
                        Label(vehicle.color, systemImage: "paintpalette.fill")
                        if let vin = vehicle.vin, !vin.isEmpty {
                            Label(vin, systemImage: "barcode")
                        }
                        if !vehicle.plateNumber.isEmpty {
                            Label(vehicle.plateNumber, systemImage: "rectangle.and.pencil.and.ellipsis")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding(.vertical)
            }
            
            // --- SERVICE HISTORY ---
            Section(header: HStack {
                Text("Service History")
                Spacer()
                Text("Total: \(vehicle.totalRevenue, format: .currency(code: "USD"))")
                    .font(.caption)
                    .foregroundStyle(Color.lynkMint)
            }) {
                if let services = vehicle.services?.sorted(by: { $0.date > $1.date }), !services.isEmpty {
                    ForEach(services) { service in
                        ServiceRowView(service: service)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            if let services = vehicle.services?.sorted(by: { $0.date > $1.date }) {
                                modelContext.delete(services[index])
                            }
                        }
                    }
                } else {
                    ContentUnavailableView("No Services Yet", systemImage: "wrench.and.screwdriver")
                }
            }
        }
        .navigationTitle("Vehicle Profile")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Edit") {
                    showEditVehicleSheet = true
                }
                Button("Add Service") {
                    showAddServiceSheet = true
                }
            }
        }
        .sheet(isPresented: $showAddServiceSheet) {
            AddServiceView(vehicle: vehicle)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showEditVehicleSheet) {
            EditVehicleView(vehicle: vehicle)
        }
    }
}

// MARK: - ISOLATED ROW SUBVIEW
// This completely fixes the "Double Navigation" bug by separating the state
struct ServiceRowView: View {
    @Bindable var service: Service
    
    // We use State variables instead of NavigationLinks to control routing safely
    @State private var navigateToDiagram = false
    @State private var navigateToPhotos = false
    
    var body: some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: 10) {
                if !service.notes.isEmpty {
                    Text("Notes: \(service.notes)")
                        .font(.caption)
                        .italic()
                }

                Text("Inspection Tools")
                    .font(.caption)
                    .secondaryText()
                    .padding(.top, 4)

                HStack(spacing: 12) {
                    
                    // 1. DIAGRAM BUTTON
                    Button(action: {
                        navigateToDiagram = true // Triggers navigation manually
                    }) {
                        VStack(spacing: 6) {
                            Image(systemName: "car.side.fill")
                                .font(.title2)
                                .foregroundStyle(Color.blue)
                            Text("Diagram")
                                .font(.caption2)
                                .bold()
                                .primaryText()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .buttonStyle(.borderless)
                    .navigationDestination(isPresented: $navigateToDiagram) {
                        InspectionView(service: service)
                    }

                    // 2. PHOTOS BUTTON
                    Button(action: {
                        navigateToPhotos = true // Triggers navigation manually
                    }) {
                        VStack(spacing: 6) {
                            Image(systemName: "camera.fill")
                                .font(.title2)
                                .foregroundStyle(Color.blue)
                            Text("Photos")
                                .font(.caption2)
                                .bold()
                                .primaryText()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .buttonStyle(.borderless)
                    .navigationDestination(isPresented: $navigateToPhotos) {
                        PhotoInspectionView(service: service)
                    }
                    
                }
                .padding(.bottom, 8)
                
                Divider()
                
                HStack {
                    // MARK AS PAID BUTTON
                    Button(action: {
                        service.isPaid.toggle()
                    }) {
                        Label(
                            service.isPaid ? "Paid" : "Mark Paid",
                            systemImage: service.isPaid ? "checkmark.circle.fill" : "circle"
                        )
                        .foregroundStyle(service.isPaid ? Color.lynkMint : .orange)
                    }
                    .buttonStyle(.borderless)
                    
                    Spacer()
                    
                    // GENERATE INVOICE BUTTON
                    Button(action: {
                        if let url = InvoiceGenerator.generateInvoice(for: service) {
                            sharePDF(url: url)
                        }
                    }) {
                        Label("Invoice", systemImage: "square.and.arrow.up")
                            .font(.caption)
                            .padding(6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                    }
                    .buttonStyle(.borderless)
                }
                .padding(.top, 5)
            }
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(service.title)
                        .font(.headline)
                    Text(service.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .secondaryText()
                }
                Spacer()
                Text(service.price, format: .currency(code: "USD"))
                    .bold()
            }
        }
    }
    
    // Helper to share the PDF
    func sharePDF(url: URL) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first,
           let rootVC = window.rootViewController {
            
            activityVC.popoverPresentationController?.sourceView = window
            activityVC.popoverPresentationController?.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
            
            rootVC.present(activityVC, animated: true)
        }
    }
}
