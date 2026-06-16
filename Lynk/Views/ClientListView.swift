//
//  ClientListView.swift
//  Lynk
//
//  Created by gülçin çetin on 2.02.2026.
//

import SwiftUI
import SwiftData

struct ClientListView: View {
    @Query(sort: \Client.name) private var clients: [Client]
    @Environment(\.modelContext) var modelContext
    
    @EnvironmentObject var store: StoreManager
    @State private var showAddSheet = false
    @State private var showPaywallAlert = false
    @State private var showPaywall = false
    
    var body: some View {
        NavigationStack {
            Group {
                if clients.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 50))
                            .foregroundStyle(Color.gray)
                        Text("No Clients Yet")
                            .font(.headline)
                            .primaryText()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(clients) { client in
                            ZStack {
                                NavigationLink(destination: ClientDetailView(client: client)) {
                                    EmptyView()
                                }
                                .opacity(0)
                                
                                ClientCard(client: client)
                            }
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                        .onDelete(perform: deleteClients)
                    }
                    .listStyle(.plain)
                    .padding(.bottom, 80)
                }
            }
            .premiumBackground()
            .navigationTitle("Clients")
            
            // 1. THE FLOATING ACTION BUTTON (FAB)
            .overlay(alignment: .bottomTrailing) {
                Button(action: {
                    if !store.hasProAccess && clients.count >= 5 {
                        showPaywallAlert = true
                    } else {
                        showAddSheet = true
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.black)
                        .frame(width: 60, height: 60)
                        .background(Color.lynkMint)
                        .clipShape(Circle())
                        .shadow(color: Color.lynkMint.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .padding()
            }
            .sheet(isPresented: $showAddSheet) {
                AddClientView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .alert("Client Limit Reached", isPresented: $showPaywallAlert) {
                Button("Got It", role: .cancel) { }
                Button("Get Pro Lynk") { showPaywall = true }
            } message: {
                Text("Free users can manage up to 5 clients. Get Pro to add more clients.")
            }
        }
    }
    
    private func deleteClients(offsets: IndexSet) {
        for index in offsets {
            let client = clients[index]
            modelContext.delete(client)
        }
    }
}

// 2. CLIENT CARD
struct ClientCard: View {
    let client: Client
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.lynkMint)
                    .frame(width: 50, height: 50)
                
                Text(client.name.prefix(1).uppercased())
                    .font(.title2.bold())
                    .foregroundStyle(Color.lynkDarkBlue)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(client.name)
                    .font(.headline)
                    .primaryText()
                
                // Phone Label
                if !client.phoneNumber.isEmpty {
                    HStack{
                        Image(systemName: "phone.fill")
                            .font(.caption)
                            .foregroundStyle(Color.lynkMint)
                        
                        Text(client.phoneNumber)
                            .font(.caption)
                            .secondaryText()
                    }
                }
                
                // Email Label
                if !client.email.isEmpty {
                    HStack{
                        Image(systemName: "envelope.fill")
                            .font(.caption)
                            .foregroundStyle(Color.blue)
                        
                        Text(client.email)
                            .font(.caption)
                            .secondaryText()
                    }
                }
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
