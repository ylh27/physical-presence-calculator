//
//  MainView.swift
//  Physical Presence Calculator
//
//  Created by Lehan Yang on 12/27/23.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var travelData: TravelData
    
    @State private var isEditing = false
    
    var body: some View {
        NavigationStack {
            List {
                Section(content: {
                    Text("PR Since " + DateToString(date: travelData.initDate, style: .long))
                    Text(String(travelData.daysSincePR()!) + " Days as PR")
                }, header: {
                    Text("Statistics")
                })
                
                
                Section(content: {
                    // TODO: add exemption data
                    Text(String(daysInCanada(travelData: travelData, exemptionData: ExemptionData(), referenceDate: Date.now)) + " days in Canada (Current Cycle)")
                    Text("Return Before " + DateToString(date: dateToReturn(travelData: travelData, exemptionData: ExemptionData()), style: .long))
                }, header:{
                    Text("Compliance")
                })
                
                Section(content: {
                    Button {
                        isEditing = true
                    } label: {
                        Text("Edit Details")
                    }
                }, header: {
                    Text("Edit")
                })
                

                Section(content: {
                    Link("About This App", destination: URL(string: "https://github.com/ylh27/physical-presence-calculator")!)
                    Link("Release Notes", destination: URL(string: "https://github.com/ylh27/physical-presence-calculator/releases")!)
                }, header: {
                    Text("About")
                })
            }
            .navigationTitle("Home")
        }
        .sheet(isPresented: $isEditing) {
            NavigationStack {
                InitView(travelData: travelData)
                
                .toolbar {
                    ToolbarItem {
                        Button {
                            isEditing = false
                        } label: {
                            Text("Done")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    MainView(travelData: TravelData())
}
