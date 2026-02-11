//
//  VehicleCard.swift
//  Lynk
//
//  Created by gülçin çetin on 10.02.2026.
//

import SwiftUI

struct VehicleCard: View {
    let vehicle: Vehicle
    
    var body: some View {
        HStack(spacing: 16) {
            // 1. The Icon (Gold Circle)
            ZStack {
                Circle()
                    .fill(Color.lynkMint.opacity(0.1))
                    .frame(width: 56, height: 56)
                
                Image(systemName: "car.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(LinearGradient.lynkMintGradient)
            }
            
            // 2. The Details
            VStack(alignment: .leading, spacing: 4) {
                Text(vehicle.make.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.gray)
                    .tracking(1)
                
                Text(vehicle.model)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                
                if !vehicle.plateNumber.isEmpty {
                    Text(vehicle.plateNumber)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(4)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            
            Spacer()
            
            // 3. The Year Badge
            Text(String(vehicle.year))
                .font(.callout)
                .bold()
                .foregroundStyle(Color.lynkMint)
        }
        .padding()
        .luxuryCardStyle() // Applies our new Theme
    }
}
