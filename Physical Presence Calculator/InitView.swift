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
        DatePicker(
            "Date",
            selection: $travelData.initDate,
            displayedComponents: [.date]
        )
    }
}

#Preview {
    InitView(travelData: TravelData())
}
