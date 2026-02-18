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
            ScrollView {
                VStack(spacing: 12) {
                    if clients.isEmpty {
                        // Empty State
                        VStack(spacing: 20) {
                            Image(systemName: "person.2.slash")
                                .font(.system(size: 50))
                                .foregroundStyle(Color.gray)
                            Text("No Clients Yet")
                                .font(.headline)
                                .primaryText()
                            Text("Add your first client to get started.")
                                .font(.caption)
                                .secondaryText()
                        }
                        .padding(.top, 50)
                    } else {
                        ForEach(clients) { client in
                            NavigationLink(destination: ClientDetailView(client: client)) {
                                ClientCard(client: client)
                            }
                        }
                    }
                }
                .padding()
            }
            .premiumBackground()
            .navigationTitle("Clients")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        if !store.hasProAccess && clients.count >= 5 {
                            showPaywallAlert = true // Blocked!
                        } else {
                            showAddSheet = true // Allowed!
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.headline)
                            .foregroundStyle(Color.lynkMint)
                            .padding(8)
                            .background(Color.lynkCardDark)
                            .clipShape(Circle())
                    }
                }
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
}

// --- NEW CLIENT CARD ---
struct ClientCard: View {
    let client: Client
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.lynkMint)
                    .frame(width: 50, height: 50)
                    .shadow(color: Color.lynkMint.opacity(0.3), radius: 5)
                
                Text(client.name.prefix(1).uppercased())
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.black)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(client.name)
                    .font(.headline)
                    .primaryText()
                Text(client.email)
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
