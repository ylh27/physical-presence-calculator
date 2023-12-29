//
//  ContentView.swift
//  Physical Presence Calculator
//
//  Created by Lehan Yang on 12/27/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var travelData: TravelData
    
    var body: some View {
        TabView {
            MainView(travelData: travelData)
                .tabItem {
                    Label("Statistics", systemImage: "timer")
                }
            
            TravelList(travelData: travelData)
                .tabItem {
                    Label("Travel List", systemImage: "list.bullet")
                }
        }
    }
}

#Preview {
    ContentView(travelData: TravelData())
}
