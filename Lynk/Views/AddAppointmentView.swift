//
//  AddAppointmentView.swift
//  Lynk
//
//  Created by gülçin çetin on 24.02.2026.
//

import SwiftUI
import SwiftData

struct AddAppointmentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State var selectedDate: Date
    @State private var title = ""
    @State private var notes = ""
    
    var isValid: Bool {
        !title.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("APPOINTMENT TITLE").font(.caption.bold()).foregroundColor(.gray)
                        TextField("e.g. Shop Maintenance", text: $title)
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .foregroundColor(.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("DATE & TIME").font(.caption.bold()).foregroundColor(.gray)
                        DatePicker("", selection: $selectedDate)
                            .datePickerStyle(.compact)
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .labelsHidden()
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("NOTES").font(.caption.bold()).foregroundColor(.gray)
                        TextField("Additional details...", text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                            .padding()
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer(minLength: 30)
                    
                    Button(action: {
                        saveAppointment()
                        dismiss()
                    }) {
                        Text("Save Appointment")
                            .font(.headline)
                            .foregroundColor(isValid ? .black : .gray)
                            .frame(maxWidth: 150)
                            .padding()
                            .background(isValid ? Color.lynkMint : Color(UIColor.secondarySystemGroupedBackground))
                            .clipShape(.capsule)
                    }
                    .disabled(!isValid)
                }
                .padding()
            }
            .premiumBackground()
            .navigationTitle("New Appointment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.lynkMint)
                }
            }
        }
    }
    
    func saveAppointment() {
        let newAppt = Appointment(title: title, date: selectedDate, notes: notes)
        modelContext.insert(newAppt)
        
        // ALARM 1: Exactly 24 hours before
        NotificationManager.shared.scheduleEarlyReminder(
            title: "Tomorrow: \(title)",
            body: "You have an appointment scheduled for tomorrow.",
            targetDate: selectedDate,
            hoursBefore: 24
        )
        
        // ALARM 2: Exactly 2 hours before
        NotificationManager.shared.scheduleEarlyReminder(
            title: "Upcoming: \(title)",
            body: "Appointment starts in 2 hours.",
            targetDate: selectedDate,
            hoursBefore: 2
        )
    }
}
