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
    
    @AppStorage("currencyCode") private var currencyCode: String = "USD"
    
    init(client: Client) {
        _viewModel = State(initialValue: ClientDetailViewModel(client: client))
    }

    var body: some View {
        List {
            // --- TOP CARD: REVENUE & CONTACT ---
            VStack(spacing: 20) {
                // Revenue Summary
                VStack(spacing: 8) {
                    Text("LIFETIME VALUE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .secondaryText()
                        .tracking(1)
                    
                    Text(viewModel.totalEarnings, format: .currency(code: currencyCode))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .primaryText()
                }
                
                Divider().background(Color.gray.opacity(0.3))
                
                // Action Buttons
                HStack(spacing: 15) {
                    Button(action: {
                        let cleanPhone = viewModel.client.phoneNumber.filter("0123456789".contains)
                        if let url = URL(string: "tel://\(cleanPhone)"), UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "phone.fill")
                            Text("Call")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.lynkMint.opacity(0.1))
                        .foregroundStyle(Color.lynkMint)
                        .cornerRadius(10)
                    }
                    .buttonStyle(.borderless)
                    
                    Button(action: {
                        if let url = URL(string: "mailto:\(viewModel.client.email)") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "envelope.fill")
                            Text("Email")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.lynkMint.opacity(0.1))
                        .foregroundStyle(Color.lynkMint)
                        .cornerRadius(10)
                    }
                    .buttonStyle(.borderless)
                }
            }
            .padding()
            .luxuryCardStyle()
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 20, trailing: 16))
            
            // --- THE GARAGE ---
            Text("CLIENT'S GARAGE")
                .font(.caption)
                .fontWeight(.bold)
                .secondaryText()
                .padding(.horizontal, 4)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            
            if let vehicles = viewModel.client.vehicles, !vehicles.isEmpty {
                ForEach(vehicles) { vehicle in
                    ZStack {
                        NavigationLink(destination: VehicleDetailView(vehicle: vehicle)) {
                            EmptyView()
                        }
                        .opacity(0)
                        
                        ClientVehicleCard(vehicle: vehicle)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 8, trailing: 16))
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            viewModel.deleteVehicle(vehicle: vehicle, context: modelContext)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            } else {
                ContentUnavailableView {
                    Label {
                        Text("No Vehicles")
                            .primaryText()
                    } icon: {
                        ZStack {
                            Image(systemName: "car.fill")
                            Image(systemName: "line.diagonal")
                                .font(.system(size: 55, weight: .bold))
                        }
                        .foregroundStyle(Color.lynkMint)
                        .font(.system(size: 45))
                    }
                } description: {
                    Text("Add a vehicle to start tracking services.")
                        .secondaryText()
                } actions: {
                    Button("Add Vehicle") { showAddVehicleSheet = true }
                        .foregroundStyle(Color.lynkMint.opacity(0.7))
                }
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .premiumBackground()
        .navigationTitle(viewModel.client.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { showEditSheet = true }
                    .foregroundStyle(Color.lynkMint)
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Add Vehicle") { showAddVehicleSheet = true }
                    .foregroundStyle(Color.lynkMint)
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

// --- SUB-VIEW ---
struct ClientVehicleCard: View {
    let vehicle: Vehicle
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 50, height: 50)
                Image(systemName: "car.fill")
                    .font(.title3)
                    .foregroundStyle(Color.blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(vehicle.year) \(vehicle.make) \(vehicle.model)")
                    .font(.headline)
                    .primaryText()
                Text(vehicle.plateNumber.isEmpty ? "No Plate Info" : vehicle.plateNumber)
                    .font(.caption)
                    .secondaryText()
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .secondaryText()
        }
        .padding()
        .luxuryCardStyle()
    }
}
