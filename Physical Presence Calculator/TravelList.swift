//
//  TravelList.swift
//  Physical Presence Calculator
//
//  Created by Lehan Yang on 12/24/23.
//

import SwiftUI

struct TravelList: View {
    @ObservedObject var travelData: TravelData
    
    @State private var selectedTab = 0 // 0 = Travels, 1 = Exemptions
    
    // States for Travel
    @State private var isAddingTravel = false
    @State private var newTravel = Travel()
    @State private var isNewTravel = false
    
    // States for Exemption
    @State private var isAddingExemption = false
    @State private var newExemption = Exemption()
    @State private var isNewExemption = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segmented Picker
                Picker("Record Type", selection: $selectedTab) {
                    Text("Travels").tag(0)
                    Text("Exemptions").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                if selectedTab == 0 {
                    // Travels List
                    List(travelData.travels) { travel in
                        TravelRow(travel: travel)
                            .swipeActions(edge: .leading) {
                                Button {
                                    newTravel = travel
                                    isNewTravel = false
                                    isAddingTravel = true
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
                } else {
                    // Exemptions List
                    List(travelData.exemptions) { exemption in
                        HStack {
                            Image(systemName: exemption.symbol)
                                .font(.title2)
                                .foregroundStyle(Color.green)
                                .frame(width: 30)
                                .padding(10)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(exemption.reason)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .lineLimit(2)
                                Text("\(exemption.startDate.toString(style: .abbreviated)) - \(exemption.endDate.toString(style: .abbreviated))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("\(exemption.durationInDays) Days Exempt")
                                    .font(.caption2)
                                    .foregroundStyle(.green)
                                    .fontWeight(.bold)
                            }
                        }
                        .padding(.vertical, 4)
                        .swipeActions(edge: .leading) {
                            Button {
                                newExemption = exemption
                                isNewExemption = false
                                isAddingExemption = true
                            } label: {
                                Label("Edit", systemImage: "slider.horizonal.3")
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                travelData.removeExemption(exemption: exemption)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Records")
            .toolbar {
                ToolbarItem {
                    Menu {
                        Button("New Travel Record") {
                            newTravel = Travel(entry: true,
                                               port: "",
                                               transport: "airplane",
                                               date: Date.from(yyyymmdd: "2020-01-01") ?? Date())
                            isNewTravel = true
                            isAddingTravel = true
                        }
                        Button("New Exemption") {
                            newExemption = Exemption(startDate: Date.from(yyyymmdd: "2020-01-01") ?? Date(),
                                                     endDate: Date.from(yyyymmdd: "2020-12-01") ?? Date(),
                                                     reason: "Accompanying a Canadian Citizen (Spouse/Partner/Parent)")
                            isNewExemption = true
                            isAddingExemption = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingTravel) {
                NavigationStack {
                    EditView(travel: $newTravel)
                    .navigationTitle(isNewTravel ? "New Travel Record" : "Edit Travel Record")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isAddingTravel = false
                            }
                        }
                        ToolbarItem {
                            Button("Save") {
                                if !isNewTravel {
                                    travelData.remove(travel: newTravel)
                                }
                                travelData.add(travel: newTravel)
                                isAddingTravel = false
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $isAddingExemption) {
                NavigationStack {
                    EditExemptionView(exemption: $newExemption)
                    .navigationTitle(isNewExemption ? "New Exemption" : "Edit Exemption")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isAddingExemption = false
                            }
                        }
                        ToolbarItem {
                            Button("Save") {
                                if !isNewExemption {
                                    travelData.removeExemption(exemption: newExemption)
                                }
                                travelData.addExemption(exemption: newExemption)
                                isAddingExemption = false
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
