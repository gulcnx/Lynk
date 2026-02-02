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
    @Environment(\.colorScheme) var colorScheme
    @State private var showAddSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(clients) { client in
                    NavigationLink(destination: ClientDetailView(client: client)) {
                        HStack(spacing: 16) {
                            // Avatar
                            ZStack {
                                Circle()
                                    .fill(Color.lynkYellow)
                                    .frame(width: 50, height: 50)
                                
                                Text(client.name.prefix(1).uppercased())
                                    .font(.title2)
                                    .bold()
                                    .foregroundStyle(.black)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(client.name)
                                    .font(.system(.headline, design: .rounded))
                                    // 👇 Dynamic Text Color
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                Text(client.email)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(client.totalRevenue, format: .currency(code: "USD"))
                                .font(.subheadline)
                                .bold()
                                .foregroundStyle(Color.lynkYellow)
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(colorScheme == .dark ? Color.lynkDarkGray : Color.white)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        modelContext.delete(clients[index])
                    }
                }
            }
            .listStyle(.plain)
            .premiumBackground() 
            .navigationTitle("Clients")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showAddSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.lynkYellow)
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddClientView()
            }
        }
    }
}
