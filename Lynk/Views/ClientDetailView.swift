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
    @State private var showAddProjectSheet = false
    @State private var showEditSheet = false
    
    init(client: Client) {
        _viewModel = State(initialValue: ClientDetailViewModel(client: client))
    }

    var body: some View {
        List {
            Section {
                HStack(spacing: 20) {
                    Button(action: {
                        let cleanPhone = viewModel.client.phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                        
                        if let phoneUrl = URL(string: "tel://\(cleanPhone)"), UIApplication.shared.canOpenURL(phoneUrl) {
                            UIApplication.shared.open(phoneUrl)
                        }
                    }) {
                        Label("Call", systemImage: "phone.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button(action: {
                        let emailUrl = URL(string: "mailto:\(viewModel.client.email)")!
                        if UIApplication.shared.canOpenURL(emailUrl) {
                            UIApplication.shared.open(emailUrl)
                        }
                    }) {
                        Label("Email", systemImage: "envelope.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.vertical, 5)
            }
            .listRowBackground(Color.clear) 
            
            Section {
                VStack(alignment: .leading) {
                    Text("Total Earnings")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(viewModel.formattedEarnings)
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(.green)
                }
            }
            
            Section(header: Text("Projects")) {
                if let projects = viewModel.client.projects, !projects.isEmpty {
                    ForEach(projects) { project in
                        NavigationLink(destination: ProjectDetailView(project: project)){
                            VStack(alignment: .leading) {
                                Text(project.title)
                                    .font(.headline)
                                HStack {
                                    Text("Due: \(project.dueDate.formatted(date: .numeric, time: .omitted))")
                                    Spacer()
                                    Button(action: {
                                            viewModel.togglePaymentStatus(for: project)
                                        }) {
                                            Text(project.isPaid ? "Paid" : "Pending")
                                                .bold()
                                                .foregroundStyle(project.isPaid ? .green : .red)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(project.isPaid ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                                                .cornerRadius(8)
                                        }
                                        .buttonStyle(.plain)
                                }
                                .font(.caption)
                                
                                Button(action: {
                                    if let url = InvoiceGenerator.generateInvoice(for: project) {
                                        // Share Sheet Logic
                                        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                                        
                                        // Get the top window scene to present the share sheet
                                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                           let window = scene.windows.first,
                                           let rootVC = window.rootViewController {
                                            
                                            // iPad support requirement
                                            activityVC.popoverPresentationController?.sourceView = window
                                            activityVC.popoverPresentationController?.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                                            
                                            rootVC.present(activityVC, animated: true)
                                        }
                                    }
                                }) {
                                    Label("Send Invoice PDF", systemImage: "square.and.arrow.up")
                                        .font(.caption)
                                }
                                .padding(.top, 5)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            if let projects = viewModel.client.projects {
                                let projectToDelete = projects[index]
                                viewModel.deleteProject(project: projectToDelete, context: modelContext)
                            }
                        }
                    }
                } else {
                    ContentUnavailableView {
                        Label("No Projects", systemImage: "clipboard")
                    } description: {
                        Text("Start a new job for this client to track hours and income.")
                    } actions: {
                        Button("Create First Project") {
                            showAddProjectSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.vertical, 40)
                }
            }
        }
        .navigationTitle(viewModel.client.name)
        .toolbar {
            ToolbarItem{
                Button("Add Project") {
                    showAddProjectSheet = true
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showAddProjectSheet) {
            AddProjectView(client: viewModel.client)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showEditSheet) {
            EditClientView(client: viewModel.client)
        }
    }
}
