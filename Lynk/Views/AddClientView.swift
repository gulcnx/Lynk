//
//  AddClientView.swift
//  Lynk
//
//  Created by gülçin çetin on 2.02.2026.
//

import SwiftUI
import SwiftData

struct AddClientView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AddClientViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Custom Text Fields
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CLIENT NAME").font(.caption.bold()).foregroundColor(.gray)
                        TextField("e.g. Paul Smith", text: $viewModel.name)
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .foregroundColor(.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("EMAIL ADDRESS").font(.caption.bold()).foregroundColor(.gray)
                        TextField("paul@example.com", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .foregroundColor(.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PHONE NUMBER").font(.caption.bold()).foregroundColor(.gray)
                        TextField("+1 (415) 234-5678", text: $viewModel.phone)
                            .keyboardType(.phonePad)
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .foregroundColor(.primary)
                            .onChange(of: viewModel.phone) { oldValue, newValue in
                                let filtered = newValue.filter { "0123456789+".contains($0) }
                                if filtered != newValue { viewModel.phone = filtered }
                            }
                    }
                    
                    Spacer(minLength: 30)
                    
                    // Big Custom Save Button
                    Button(action: {
                        viewModel.saveClient(context: modelContext)
                        dismiss()
                    }) {
                        Text("Save Client")
                            .font(.headline)
                            .foregroundColor(viewModel.isValid ? .black : .gray)
                            .frame(maxWidth: 150)
                            .padding()
                            .background(viewModel.isValid ? Color.lynkMint : Color(UIColor.secondarySystemGroupedBackground))
                            .clipShape(.capsule)
                    }
                    .disabled(!viewModel.isValid)
                    
                }
                .padding()
            }
            .premiumBackground()
            .navigationTitle("New Client")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.lynkMint)
                }
            }
        }
    }
}
