//
//  Physical_Presence_CalculatorApp.swift
//  Physical Presence Calculator
//
//  Created by Lehan Yang on 12/24/23.
//

import SwiftUI

@main
struct Physical_Presence_CalculatorApp: App {
    @StateObject private var travelData = TravelData();
    
    var body: some Scene {
        WindowGroup {
            ContentView(travelData: travelData)
                .task {
                    travelData.load()
                    travelData.loadDate()
                }
                .onChange(of: travelData.travels) { _ in
                    travelData.save()
                }
                .onChange(of: travelData.initDate) { _ in
                    travelData.saveDate()
                }
        }
    }
}
