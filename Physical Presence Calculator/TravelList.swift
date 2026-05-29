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
            ZStack {
                // Premium background styling
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                // Subtle ambient glows
                VStack {
                    HStack {
                        Circle()
                            .fill(Color.blue.opacity(0.04))
                            .frame(width: 200, height: 200)
                            .blur(radius: 40)
                            .offset(x: -60, y: -40)
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        Circle()
                            .fill(Color.purple.opacity(0.04))
                            .frame(width: 200, height: 200)
                            .blur(radius: 40)
                            .offset(x: 60, y: 40)
                    }
                }
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Segmented Picker Wrapper
                    VStack(spacing: 0) {
                        Picker("Record Type", selection: $selectedTab) {
                            Text("Travels").tag(0)
                            Text("Exemptions").tag(1)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .shadow(color: .black.opacity(0.015), radius: 4, y: 1)
                    
                    if selectedTab == 0 {
                        // Travels List
                        List(travelData.travels) { travel in
                            TravelRow(travel: travel)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
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
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    } else {
                        // Exemptions List
                        List(travelData.exemptions) { exemption in
                            HStack(spacing: 16) {
                                // Exemption Symbol Circle Badge
                                ZStack {
                                    Circle()
                                        .fill(LinearGradient(colors: [.teal.opacity(0.12), .green.opacity(0.12)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 46, height: 46)
                                    
                                    Image(systemName: exemption.symbol)
                                        .font(.title3)
                                        .foregroundStyle(.green)
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(alignment: .top) {
                                        Text(exemption.reason.isEmpty ? "Accompanying PR / Business" : exemption.reason)
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.primary)
                                            .lineLimit(2)
                                        
                                        Spacer()
                                        
                                        // Days Exempt Badge
                                        Text("\(exemption.durationInDays) Days Exempt")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.green)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Capsule().fill(Color.green.opacity(0.1)))
                                    }
                                    
                                    HStack {
                                        Image(systemName: "calendar")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        
                                        Text("\(exemption.startDate.toString(style: .abbreviated)) - \(exemption.endDate.toString(style: .abbreviated))")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                                    .shadow(color: .black.opacity(0.015), radius: 6, y: 2)
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
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
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
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
                                               date: Date())
                            isNewTravel = true
                            isAddingTravel = true
                        }
                        Button("New Exemption") {
                            newExemption = Exemption(startDate: Date(),
                                                     endDate: Date(),
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
