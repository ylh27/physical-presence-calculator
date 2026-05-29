//
//  ContentView.swift
//  Physical Presence Calculator
//
//  Created by Lehan Yang on 12/27/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var travelData: TravelData
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        if hasCompletedOnboarding {
            TabView {
                MainView(travelData: travelData)
                    .tabItem {
                        Label("Dashboard", systemImage: "house")
                    }
                
                TravelList(travelData: travelData)
                    .tabItem {
                        Label("Records", systemImage: "list.bullet")
                    }
                
                MenuView(travelData: travelData)
                    .tabItem {
                        Label("Menu", systemImage: "ellipsis")
                    }
            }
        } else {
            OnboardingView(travelData: travelData, hasCompletedOnboarding: $hasCompletedOnboarding)
                .transition(AnyTransition.asymmetric(
                    insertion: AnyTransition.identity,
                    removal: AnyTransition.opacity.combined(with: AnyTransition.move(edge: .bottom))
                ))
        }
    }
}

#Preview {
    ContentView(travelData: TravelData())
}
