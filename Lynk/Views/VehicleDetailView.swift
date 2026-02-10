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
                    .foregroundStyle(.green)
            }) {
                if let services = vehicle.services?.sorted(by: { $0.date > $1.date }), !services.isEmpty {
                    ForEach(services) { service in
                        // Expandable Service Row
                        DisclosureGroup {
                            VStack(alignment: .leading, spacing: 10) {
                                if !service.notes.isEmpty {
                                    Text("Notes: \(service.notes)")
                                        .font(.caption)
                                        .italic()
                                }

                                Text("Inspection Tools")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 4)

                                HStack(spacing: 12) {
                                    NavigationLink(destination: InspectionView(service: service)) {
                                        VStack(spacing: 6) {
                                            Image(systemName: "car.side.fill")
                                                .font(.title2)
                                                .foregroundStyle(.blue)
                                            Text("Diagram")
                                                .font(.caption2)
                                                .bold()
                                                .foregroundStyle(.primary)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(10)
                                    }
                                    .buttonStyle(.plain)

                                    // 2. THE PHOTOS (Evidence)
                                    NavigationLink(destination: PhotoInspectionView(service: service)) {
                                        VStack(spacing: 6) {
                                            Image(systemName: "camera.fill")
                                                .font(.title2)
                                                .foregroundStyle(.blue)
                                            Text("Photos")
                                                .font(.caption2)
                                                .bold()
                                                .foregroundStyle(.primary)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(10)
                                    }
                                    .buttonStyle(.plain)
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
                                        .foregroundStyle(service.isPaid ? .green : .orange)
                                    }
                                    .buttonStyle(.plain)
                                    
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
                                    .buttonStyle(.plain)
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
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(service.price, format: .currency(code: "USD"))
                                    .bold()
                            }
                        }
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
            Button("Add Service") {
                showAddServiceSheet = true
            }
        }
        .sheet(isPresented: $showAddServiceSheet) {
            AddServiceView(vehicle: vehicle)
                .presentationDetents([.medium])
        }
    }
    
    // Helper to share the PDF
    func sharePDF(url: URL) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        // Find the top View Controller to present this
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first,
           let rootVC = window.rootViewController {
            
            // iPad support
            activityVC.popoverPresentationController?.sourceView = window
            activityVC.popoverPresentationController?.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
            
            rootVC.present(activityVC, animated: true)
        }
    }
}
