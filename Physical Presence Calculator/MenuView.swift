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
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                // Subtle glows
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
                }
                .ignoresSafeArea()
                
                List {
                    Section {
                        menuRow(icon: "calendar", iconBgColor: .blue, title: "PR Date", value: travelData.initDate.toString(style: .long))
                        menuRow(icon: "clock.fill", iconBgColor: .purple, title: "Time as PR", value: "\(travelData.daysSincePR() ?? 0) Days")
                        if travelData.wasTemporaryResident {
                            menuRow(icon: "person.badge.key.fill", iconBgColor: .purple, title: "Pre-PR Start", value: travelData.tempResidentDate.toString(style: .long))
                        }
                        menuRow(icon: "pencil", iconBgColor: .orange, title: "Edit Details") {
                            isEditing = true
                        }
                    } header: {
                        Text("Personal Information")
                    }
                    .listRowBackground(Color(uiColor: .secondarySystemGroupedBackground))
                    
                    Section {
                        menuLinkRow(icon: "info.circle.fill", iconBgColor: .teal, title: "About This App", destination: URL(string: "https://github.com/ylh27/physical-presence-calculator")!)
                        menuLinkRow(icon: "sparkles", iconBgColor: .indigo, title: "Release Notes", destination: URL(string: "https://github.com/ylh27/physical-presence-calculator/releases")!)
                    } header: {
                        Text("About")
                    }
                    .listRowBackground(Color(uiColor: .secondarySystemGroupedBackground))
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
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
                                    .fontWeight(.semibold)
                            }
                        }
                    }
            }
        }
    }
    
    private func menuRow(icon: String, iconBgColor: Color, title: String, value: String? = nil, action: (() -> Void)? = nil) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconBgColor)
                    .frame(width: 28, height: 28)
                Image(systemName: icon)
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
            
            Text(title)
                .font(.body)
                .foregroundStyle(.primary)
            
            Spacer()
            
            if let value = value {
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            if action != nil {
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary.opacity(0.5))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            action?()
        }
    }
    
    private func menuLinkRow(icon: String, iconBgColor: Color, title: String, destination: URL) -> some View {
        Link(destination: destination) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconBgColor)
                        .frame(width: 28, height: 28)
                    Image(systemName: icon)
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                
                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Image(systemName: "arrow.up.forward.app")
                    .font(.caption)
                    .foregroundStyle(.secondary.opacity(0.5))
            }
        }
    }
}

#Preview {
    MenuView(travelData: TravelData())
}
