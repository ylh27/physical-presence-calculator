//
//  TravelRow.swift
//  Physical Presence Calculator
//
//  Created by Lehan Yang on 12/27/23.
//

import SwiftUI

struct TravelRow: View {
    let travel: Travel
    
    var body: some View {
        HStack(spacing: 16) {
            // Direction Badge
            ZStack {
                Circle()
                    .fill(travel.entry ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: travel.symbol)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(travel.entry ? .green : .orange)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(travel.port.isEmpty ? "Unknown Port" : travel.port)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Transport badge
                    HStack(spacing: 4) {
                        Image(systemName: travel.transport)
                            .font(.caption)
                        Text(transportName(travel.transport))
                            .font(.caption2)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .foregroundStyle(.secondary)
                    .background(Capsule().fill(Color(uiColor: .systemGroupedBackground)))
                }
                
                HStack {
                    Text(travel.entry ? "Arrival" : "Departure")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(travel.entry ? .green : .orange)
                    
                    Text("•")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Text(travel.date.toString(style: .complete))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.015), radius: 6, y: 2)
        )
    }
    
    private func transportName(_ transport: String) -> String {
        switch transport {
        case "airplane": return "Flight"
        case "tram": return "Train"
        case "ferry": return "Boat"
        case "bus": return "Bus"
        case "car": return "Car"
        default: return "On Foot"
        }
    }
}

#Preview {
    TravelRow(travel: Travel())
}
