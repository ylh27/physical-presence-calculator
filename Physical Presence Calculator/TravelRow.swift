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
        HStack {
            Image(systemName: travel.symbol)
            Image(systemName: travel.transport)
                .padding(15)
            VStack(alignment: .leading) {
                Text(travel.port)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                
                Text(travel.date.formatted(date: .complete, time: .omitted))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    TravelRow(travel: Travel())
}
