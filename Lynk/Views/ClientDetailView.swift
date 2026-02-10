//
//  ClientDetailView.swift
//  Lynk
//
//  Created by gülçin çetin on 2.02.2026.
//

import SwiftUI
import SwiftData

struct ClientDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @State var viewModel: ClientDetailViewModel
    @State private var showAddVehicleSheet = false
    @State private var showEditSheet = false
    
    init(client: Client) {
        _viewModel = State(initialValue: ClientDetailViewModel(client: client))
    }

    var body: some View {
        List {
            // --- HEADER (Contact Info) ---
            Section {
                HStack(spacing: 20) {
                    // Call Button
                    Button(action: {
                        let cleanPhone = viewModel.client.phoneNumber.filter("0123456789".contains)
                        if let url = URL(string: "tel://\(cleanPhone)"), UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Label("Call", systemImage: "phone.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    // Email Button
                    Button(action: {
                        if let url = URL(string: "mailto:\(viewModel.client.email)") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Label("Email", systemImage: "envelope.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.vertical, 5)
                .listRowBackground(Color.clear)
            }
            
            // --- REVENUE SUMMARY ---
            Section {
                VStack(alignment: .leading) {
                    Text("Lifetime Value")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(viewModel.formattedEarnings)
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(.green)
                }
            }
            
            // --- THE GARAGE (Vehicles List) ---
            Section(header: Text("Garage (Vehicles)")) {
                if let vehicles = viewModel.client.vehicles, !vehicles.isEmpty {
                    ForEach(vehicles) { vehicle in
                        NavigationLink(destination: VehicleDetailView(vehicle: vehicle)) {
                            HStack {
                                Image(systemName: "car.fill")
                                    .font(.title2)
                                    .foregroundStyle(.blue)
                                    .frame(width: 40)
                                
                                VStack(alignment: .leading) {
                                    Text("\(vehicle.year) \(vehicle.make) \(vehicle.model)")
                                        .font(.headline)
                                    Text(vehicle.plateNumber.isEmpty ? "No Plate" : vehicle.plateNumber)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            if let vehicles = viewModel.client.vehicles {
                                viewModel.deleteVehicle(vehicle: vehicles[index], context: modelContext)
                            }
                        }
                    }
                } else {
                    ContentUnavailableView {
                        Label("No Vehicles", systemImage: "car")
                    } description: {
                        Text("Add a vehicle to start tracking services.")
                    } actions: {
                        Button("Add Vehicle") { showAddVehicleSheet = true }
                    }
                }
            }
        }
        .navigationTitle(viewModel.client.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add Vehicle") { showAddVehicleSheet = true }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { showEditSheet = true }
            }
        }
        .sheet(isPresented: $showAddVehicleSheet) {
            AddVehicleView(client: viewModel.client)
        }
        .sheet(isPresented: $showEditSheet) {
            EditClientView(client: viewModel.client)
        }
    }
}
