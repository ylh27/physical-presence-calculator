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
    
    var body: some View {
        NavigationStack {
            List(travelData.travels) { travel in
                TravelRow(travel: travel)
                    .swipeActions(edge: .leading) {
                        Button {
                            isAdding = true
                            newTravel = travel
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
                    Button {
                        isAdding = true
                        newTravel = Travel()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAdding) {
                NavigationStack {
                    EditView(travel: newTravel)
                }
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
                            travelData.add(travel: newTravel)
                            isAdding = false
                        } label: {
                            Text("Add")
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
