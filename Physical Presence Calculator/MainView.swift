//
//  MainView.swift
//  Physical Presence Calculator
//
//  Created by Lehan Yang on 12/27/23.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var travelData: TravelData
    
    var body: some View {
        NavigationStack {
            List {
                Text("text")
                Text(travelData.initDate.formatted(date: .complete, time: .omitted))
                
            }
            NavigationLink(destination: InitView(travelData: travelData)) {
                Text("Change Details")
            }
            .navigationTitle("Statistics")
        }
    }
}

#Preview {
    MainView(travelData: TravelData())
}
