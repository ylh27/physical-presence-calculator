//
//  InitView.swift
//  Physical Presence Calculator
//
//  Created by Lehan Yang on 12/29/23.
//

import SwiftUI

struct InitView: View {
    @ObservedObject var travelData: TravelData
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // PR Date Card
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        Image(systemName: "calendar")
                            .font(.title2)
                            .foregroundStyle(.blue)
                        
                        Text("Permanent Residency Date")
                            .font(.headline)
                        
                        Spacer()
                    }
                    
                    DatePicker(
                        "PR Date",
                        selection: $travelData.initDate,
                        in: ...Date.now,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .environment(\.timeZone, TimeZone(identifier: "Canada/Central") ?? TimeZone.current)
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(uiColor: .systemGroupedBackground)))
                    
                    HStack {
                        Text("Selected Date:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(travelData.initDate.toString(style: .long))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.blue)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .secondarySystemGroupedBackground)))
                .shadow(color: .black.opacity(0.02), radius: 8, y: 3)
                
                // Temporary Residence Card
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        Image(systemName: "person.badge.key")
                            .font(.title2)
                            .foregroundStyle(.purple)
                        
                        Text("Pre-PR Status")
                            .font(.headline)
                        
                        Spacer()
                    }
                    
                    Toggle(isOn: $travelData.wasTemporaryResident.animation(.spring())) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Temporary Resident before PR")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Held study/work permit or visitor visa")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    if travelData.wasTemporaryResident {
                        Divider()
                        
                        DatePicker(
                            "Status Start Date",
                            selection: $travelData.tempResidentDate,
                            in: ...travelData.initDate,
                            displayedComponents: [.date]
                        )
                        .environment(\.timeZone, TimeZone(identifier: "Canada/Central") ?? TimeZone.current)
                        .padding(4)
                        
                        HStack {
                            Text("Selected Start Date:")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(travelData.tempResidentDate.toString(style: .long))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.purple)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top, spacing: 6) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundStyle(.purple)
                                    .font(.caption)
                                    .padding(.top, 2)
                                Text("Each day in Canada as a temporary resident counts as 0.5 days toward your citizenship requirement, up to a maximum of 365 days.")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.purple.opacity(0.05)))
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .secondarySystemGroupedBackground)))
                .shadow(color: .black.opacity(0.02), radius: 8, y: 3)
                
                // Government Regulation Warning Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                            .font(.title3)
                        
                        Text("Legal Notice")
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                    
                    Text("This application is an unofficial tool and is not associated with or endorsed by the Government of Canada.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    
                    Text("Always refer to the official resources and guidelines of the Government of Canada for official residency requirements and final determinations.")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.orange.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Edit PR Date")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    InitView(travelData: TravelData())
}
