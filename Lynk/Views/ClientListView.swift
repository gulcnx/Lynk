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
            // 👇 CHANGE 1: Use a List instead of ScrollView for better performance & swipe actions
            List {
                if clients.isEmpty {
                    // Empty State
                    ContentUnavailableView {
                        Label("No Clients Yet", systemImage: "person.2.slash")
                    } description: {
                        Text("Add your first client to get started.")
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(clients) { client in
                        ZStack {
                            // Invisible Navigation Link (The "SwiftUI Way" to hide arrows)
                            NavigationLink(destination: ClientDetailView(client: client)) {
                                EmptyView()
                            }
                            .opacity(0)
                            
                            // The Visible Card
                            ClientCard(client: client)
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)) // Add spacing
                        .listRowBackground(Color.clear) // Make row transparent
                        .listRowSeparator(.hidden) // Hide ugly lines
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            modelContext.delete(clients[index])
                        }
                    }
                }
            }
            .listStyle(.plain) // Standard list style
            .scrollContentBackground(.hidden) // 👇 CRITICAL: Makes list transparent so background shows!
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
            // Mint Avatar
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
                    .primaryText() // Theme dynamic color
                Text(client.email)
                    .font(.caption)
                    .secondaryText() // Theme dynamic color
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .secondaryText()
                .opacity(0.5)
        }
        .padding()
        .luxuryCardStyle() // Uses your Theme
    }
}
