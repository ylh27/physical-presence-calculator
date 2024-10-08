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
                .frame(width: 20)
            Image(systemName: travel.transport)
                .frame(width: 30)
                .padding(15)
            VStack(alignment: .leading) {
                Text(travel.port)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                
                Text(DateToString(date: travel.date, style: .complete))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    TravelRow(travel: Travel())
}
