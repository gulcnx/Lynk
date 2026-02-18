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
    @State private var showAddSheet = false
    
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
                                .primaryText() // 👈 Fixed
                            Text("Add your first client to get started.")
                                .font(.caption)
                                .secondaryText() // 👈 Fixed
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
                    Button(action: { showAddSheet = true }) {
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
                    .primaryText() // 👈 Fixed White Text Bug
                Text(client.email)
                    .font(.caption)
                    .secondaryText() // 👈 Fixed
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
