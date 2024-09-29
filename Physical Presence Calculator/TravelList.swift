//
//  TravelList.swift
//  Physical Presence Calculator
//
//  Created by Lehan Yang on 12/24/23.
//

import SwiftUI

struct TravelList: View {
    @ObservedObject var travelData: TravelData
    
    @State private var isAdding = false
    @State private var newTravel = Travel()
    @State private var isNew = false
    
    var body: some View {
        NavigationStack {
            List(travelData.travels) { travel in
                TravelRow(travel: travel)
                    .swipeActions(edge: .leading) {
                        Button {
                            newTravel = travel
                            isNew = false
                            isAdding = true
                        } label: {
                            Label("Edit", systemImage: "slider.horizonal.3")
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            travelData.remove(travel: travel)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
            
            .navigationTitle("Travel List")
            .toolbar {
                ToolbarItem {
                    Menu{
                        Button("New Travel Record") {
                            newTravel = Travel(entry: true,
                                               port: "",
                                               transport: "airplane",
                                               date: TravelDate(date: "2020-01-01")!)
                            isNew = true
                            isAdding = true
                        }
                        Button("New Exemption") {
                            
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAdding) {
                NavigationStack {
                    EditView(travel: $newTravel)
                    
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button {
                                isAdding = false
                            } label: {
                                Text("Cancel")
                            }
                        }
                        ToolbarItem {
                            Button {
                                if isNew == false {
                                    travelData.remove(travel: newTravel)
                                }
                                travelData.add(travel: newTravel)
                                isAdding = false
                            } label: {
                                Text("Save")
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    TravelList(travelData: TravelData())
}
