//
//  CalendarView.swift
//  Lynk
//
//  Created by gülçin çetin on 24.02.2026.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var allAppointments: [Appointment]
    @Query private var allServices: [Service]
    
    @State private var selectedDate: Date = Date()
    @State private var currentMonth: Date = Date()
    @State private var showAddSheet = false
    
    var allEvents: [CalendarEvent] {
        var events: [CalendarEvent] = []
        for a in allAppointments {
            events.append(CalendarEvent(originalApptId: a.persistentModelID, vehicle: nil, title: a.title, date: a.date, subtitle: a.client?.name ?? "General Task", isService: false))
        }
        for s in allServices {
            let carName = s.vehicle != nil ? "\(s.vehicle!.year) \(s.vehicle!.make)" : "Service"
            events.append(CalendarEvent(originalApptId: nil, vehicle: s.vehicle, title: s.title, date: s.date, subtitle: carName, isService: true))
        }
        return events
    }
    
    var filteredEvents: [CalendarEvent] {
        allEvents.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
            .sorted { $0.date < $1.date }
    }
    
    let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // --- CUSTOM CALENDAR HEADER ---
                VStack(spacing: 15) {
                    HStack {
                        Text(currentMonth.formatted(.dateTime.month(.wide).year()))
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                        Spacer()
                        
                        HStack(spacing: 20) {
                            Button(action: { currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth }) {
                                Image(systemName: "chevron.left").font(.title3.bold()).foregroundColor(.lynkMint)
                            }
                            Button(action: { currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth }) {
                                Image(systemName: "chevron.right").font(.title3.bold()).foregroundColor(.lynkMint)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    HStack(spacing: 0) {
                        ForEach(days, id: \.self) { day in
                            Text(day).font(.caption.bold()).foregroundColor(.gray).frame(maxWidth: .infinity)
                        }
                    }
                    
                    let columns = Array(repeating: GridItem(.flexible()), count: 7)
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(extractDates()) { value in
                            CardView(value: value)
                                .onTapGesture {
                                    if value.isCurrentMonth { selectedDate = value.date }
                                }
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(16)
                .padding()
                
                // --- EVENTS LIST BELOW CALENDAR ---
                List {
                    if filteredEvents.isEmpty {
                        Text("No appointments for this day.")
                            .font(.subheadline).foregroundColor(.gray)
                            .listRowBackground(Color.clear)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 20)
                    } else {
                        ForEach(filteredEvents) { event in
                            if let vehicle = event.vehicle {
                              
                                NavigationLink(destination: VehicleDetailView(vehicle: vehicle)) {
                                    EventRow(event: event)
                                }
                                .listRowBackground(Color.clear)
                            } else {
                                if let apptId = event.originalApptId,
                                   let appt = allAppointments.first(where: { $0.persistentModelID == apptId }) {
                                    
                                    NavigationLink(destination: AppointmentDetailView(appointment: appt)) {
                                        EventRow(event: event)
                                    }
                                    .listRowBackground(Color.clear)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            deleteAppointment(event)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .premiumBackground()
            .navigationTitle("Calendar")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showAddSheet = true }) {
                        Image(systemName: "plus").foregroundColor(.lynkMint)
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddAppointmentView(selectedDate: selectedDate)
            }
            .onAppear {
                NotificationManager.shared.requestPermission()
            }
        }
    }
    
    @ViewBuilder
    func EventRow(event: CalendarEvent) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(event.title)
                    .font(.headline).foregroundColor(.primary)
                
                HStack {
                    Image(systemName: event.isService ? "car.fill" : "person.fill")
                    Text("\(event.date.formatted(date: .omitted, time: .shortened)) • \(event.subtitle)")
                }
                .font(.caption).foregroundColor(.gray)
            }
            Spacer()
            
            Text(event.isService ? "Service" : "Appt")
                .font(.caption2).bold()
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(event.isService ? Color.lynkMint.opacity(0.2) : Color.blue.opacity(0.2))
                .foregroundColor(event.isService ? .lynkMint : .blue)
                .cornerRadius(8)
        }
        .padding(.vertical, 4)
    }
    
    private func deleteAppointment(_ event: CalendarEvent) {
        guard let id = event.originalApptId else { return }
        if let appt = allAppointments.first(where: { $0.persistentModelID == id }) {
            modelContext.delete(appt)
        }
    }
    
    @ViewBuilder
    func CardView(value: DateValue) -> some View {
        VStack(spacing: 4) {
            if value.isCurrentMonth {
                let isSelected = Calendar.current.isDate(value.date, inSameDayAs: selectedDate)
                let isToday = Calendar.current.isDateInToday(value.date)
                
                Text("\(Calendar.current.component(.day, from: value.date))")
                    .font(.title3)
                    // ADAPTS: .primary flips between black/white based on system mode
                    .foregroundColor(isSelected ? .black : (isToday ? .lynkMint : .primary))
                    .frame(width: 35, height: 35)
                    .background(Circle().fill(isSelected ? Color.lynkMint : Color.clear))
                
                let dayEvents = allEvents.filter { Calendar.current.isDate($0.date, inSameDayAs: value.date) }
                if !dayEvents.isEmpty {
                    HStack(spacing: 2) {
                        ForEach(dayEvents.prefix(3)) { event in
                            Circle()
                                .fill(event.isService ? Color.lynkMint : Color.blue)
                                .frame(width: 5, height: 5)
                        }
                    }
                } else {
                    Spacer().frame(height: 5)
                }
            } else {
                Text("\(Calendar.current.component(.day, from: value.date))")
                    .font(.title3).foregroundColor(.gray.opacity(0.3)).frame(width: 35, height: 35)
                Spacer().frame(height: 5)
            }
        }
    }
    
    func extractDates() -> [DateValue] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else { return [] }
        guard let firstWeekInterval = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else { return [] }
        guard let lastWeekInterval = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1) else { return [] }
        
        var dates: [DateValue] = []
        var currentDate = firstWeekInterval.start
        
        while currentDate < lastWeekInterval.end {
            let isCurrentMonth = calendar.isDate(currentDate, equalTo: currentMonth, toGranularity: .month)
            dates.append(DateValue(date: currentDate, isCurrentMonth: isCurrentMonth))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        return dates
    }
}
