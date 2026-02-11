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
                    Label("Dashboard", systemImage: "house")
                }
            
            TravelList(travelData: travelData)
                .tabItem {
                    Label("Travel Record", systemImage: "list.bullet")
                }
            
            MenuView(travelData: travelData)
                .tabItem {
                    Label("Menu", systemImage: "ellipsis")
                }
        }
    }
}

#Preview {
    ContentView(travelData: TravelData())
}
