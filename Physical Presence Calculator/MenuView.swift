//
//  MenuView.swift
//  Physical Presence Calculator
//
//  Created by Lehan Yang on 2026-02-11.
//

import SwiftUI

struct MenuView: View {
    @ObservedObject var travelData: TravelData
    
    @State private var isEditing = false
    
    var body: some View {
        NavigationStack {
            List {
                Section(content: {
                    Text("PR Since " + travelData.initDate.toString(style: .long))
                    Text("\(travelData.daysSincePR() ?? 0) Days as PR")
                    Button {
                        isEditing = true
                    } label: {
                        Text("Edit Details")
                    }
                }, header: {
                    Text("Personal Information")
                })

                Section(content: {
                    Link("About This App", destination: URL(string: "https://github.com/ylh27/physical-presence-calculator")!)
                    Link("Release Notes", destination: URL(string: "https://github.com/ylh27/physical-presence-calculator/releases")!)
                }, header: {
                    Text("About")
                })
            }
            .navigationTitle("Menu")
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
    MenuView(travelData: TravelData())
}
