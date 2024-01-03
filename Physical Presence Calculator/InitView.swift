//
//  InitView.swift
//  Physical Presence Calculator
//
//  Created by Lehan Yang on 12/29/23.
//

import SwiftUI

struct InitView: View {
    @ObservedObject var travelData: TravelData
    
    var body: some View {
        List {
            DatePicker(
                "PR Since",
                selection: $travelData.initDate,
                displayedComponents: [.date]
            )
            .environment(\.timeZone, TimeZone(identifier: "Canada/Central")!)
        }
    }
}

#Preview {
    InitView(travelData: TravelData())
}
