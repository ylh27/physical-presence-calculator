//
//  Physical_Presence_CalculatorApp.swift
//  Physical Presence Calculator
//
//  Created by Lehan Yang on 12/24/23.
//

import SwiftUI

@main
struct Physical_Presence_CalculatorApp: App {
    @StateObject private var travelData = TravelData()
    
    var body: some Scene {
        WindowGroup {
            ContentView(travelData: travelData)
                .task {
                    await travelData.load()
                    await travelData.loadDate()
                    await travelData.loadTempResident()
                }
                .onChange(of: travelData.travels) { _, _ in
                    Task {
                        await travelData.save()
                    }
                }
                .onChange(of: travelData.exemptions) { _, _ in
                    Task {
                        await travelData.save()
                    }
                }
                .onChange(of: travelData.initDate) { _, _ in
                    Task {
                        await travelData.saveDate()
                    }
                }
                .onChange(of: travelData.wasTemporaryResident) { _, _ in
                    Task {
                        await travelData.saveTempResident()
                    }
                }
                .onChange(of: travelData.tempResidentDate) { _, _ in
                    Task {
                        await travelData.saveTempResident()
                    }
                }
        }
    }
}
