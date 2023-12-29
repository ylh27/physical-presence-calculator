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
                Text("PR Since " + travelData.initDate.formatted(date: .abbreviated, time: .omitted))
                
                Button {
                    isEditing = true
                } label: {
                    Text("Edit Details")
                }
            }
            .navigationTitle("Statistics")
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
