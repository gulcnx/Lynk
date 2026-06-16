//
//  InspectionView.swift
//  Lynk
//
//  Created by gülçin çetin on 9.02.2026.
//

import SwiftUI
import SwiftData

struct InspectionView: View {
    @Bindable var service: Service
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        VStack {
            Text("Tap to mark damage")
                .font(.headline)
            
            // THE CAR DIAGRAM CANVAS
            GeometryReader { geo in
                ZStack {
                    // 1. The Car Image
                    Image(systemName: "car.side.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Color.blue.opacity(0.15))
                        .overlay(
                            Image(systemName: "car.side")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(Color.blue.opacity(0.5))
                        )
                        .frame(width: geo.size.width, height: geo.size.height)
                        .onTapGesture { location in
                            addDamagePoint(at: location, in: geo.size)
                        }
                    
                    // 2. The Red Dots (Damage Points)
                    if let points = service.damagePoints {
                        ForEach(points) { point in
                            Circle()
                                .fill(.red)
                                .frame(width: 20, height: 20)
                                .position(
                                    x: point.x * geo.size.width,
                                    y: point.y * geo.size.height
                                )
                                .onTapGesture {
                                    // Tap a dot to delete it
                                    modelContext.delete(point)
                                }
                        }
                    }
                }
            }
            .frame(height: 300) // Fixed height for the car area
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 5)
            
            // List of damages below
            List {
                if let points = service.damagePoints, !points.isEmpty {
                    ForEach(points) { point in
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundStyle(.red)
                            Text(point.note.isEmpty ? "Damage Point" : point.note)
                            Spacer()
                        }
                    }
                } else {
                    Text("No damage marked.")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .navigationTitle("Inspection")
    }
    
    func addDamagePoint(at location: CGPoint, in size: CGSize) {
        // Convert screen coordinates to Percentage (0.0 to 1.0)
        // This ensures the dots stay in the right place even if screen size changes
        let xPercent = location.x / size.width
        let yPercent = location.y / size.height
        
        let newPoint = DamagePoint(x: xPercent, y: yPercent, note: "Scratch")
        newPoint.service = service // Link it
        modelContext.insert(newPoint)
    }
}
