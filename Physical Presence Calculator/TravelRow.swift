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
            Label {
                VStack(alignment: .leading) {
                    Text(travel.title)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    
                    Text(travel.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: travel.symbol)
                    .padding(.trailing, 15)
            }
        }
    }
}

#Preview {
    TravelRow(travel: Travel())
}
