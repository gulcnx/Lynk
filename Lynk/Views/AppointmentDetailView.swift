//
//  AppointmentDetailView.swift
//  Lynk
//
//  Created by gülçin çetin on 26.02.2026.
//

import SwiftUI
import SwiftData

struct AppointmentDetailView: View {
    var appointment: Appointment
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // --- HEADER ---
                VStack(spacing: 12) {
                    Image(systemName: "calendar.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(Color.lynkMint)
                    
                    Text(appointment.title)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                    
                    Text(appointment.date.formatted(date: .complete, time: .shortened))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                
                // --- NOTES SECTION ---
                if !appointment.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("NOTES")
                            .font(.caption.bold())
                            .foregroundColor(.gray)
                        
                        Text(appointment.notes)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            // ADAPTS: Light/Dark mode background
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                    }
                } else {
                    Text("No additional notes.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                }
                
                Spacer()
            }
            .padding()
        }
        .premiumBackground()
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
