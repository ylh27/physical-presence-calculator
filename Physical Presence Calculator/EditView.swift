//
//  EditView.swift
//  Physical Presence Calculator
//
//  Created by Lehan Yang on 12/27/23.
//

import SwiftUI

struct EditView: View {
    @Binding var travel: Travel
    
    let transportationOptions = [
        ("airplane", "Flight", Color.blue),
        ("car", "Car", Color.green),
        ("tram", "Train", Color.orange),
        ("bus", "Bus", Color.purple),
        ("ferry", "Boat", Color.cyan),
        ("figure.wave", "On Foot", Color.indigo)
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Card 1: Port & Direction
                VStack(spacing: 16) {
                    HStack(spacing: 10) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.headline)
                            .foregroundStyle(.blue)
                        Text("Port & Direction")
                            .font(.headline)
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Port Name")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                        
                        TextField("e.g. Montréal-Trudeau, Windsor Bridge", text: $travel.port)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(uiColor: .systemGroupedBackground)))
                            .font(.body)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Direction")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                        
                        Picker("Entry/Exit", selection: $travel.entry) {
                            Text("Arrival / Entry").tag(true)
                            Text("Departure / Exit").tag(false)
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .secondarySystemGroupedBackground)))
                .shadow(color: .black.opacity(0.02), radius: 8, y: 3)
                
                // Card 2: Transportation Grid/Selector
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 10) {
                        Image(systemName: "box.truck.fill")
                            .font(.headline)
                            .foregroundStyle(.purple)
                        Text("Mode of Transportation")
                            .font(.headline)
                        Spacer()
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(transportationOptions, id: \.0) { option in
                                let isSelected = travel.transport == option.0
                                Button {
                                    travel.transport = option.0
                                } label: {
                                    VStack(spacing: 8) {
                                        ZStack {
                                            Circle()
                                                .fill(isSelected ? option.2.opacity(0.12) : Color(uiColor: .systemGroupedBackground))
                                                .frame(width: 52, height: 52)
                                                .overlay(
                                                    Circle()
                                                        .stroke(isSelected ? option.2 : Color.clear, lineWidth: 2)
                                                )
                                            
                                            Image(systemName: option.0)
                                                .font(.title3)
                                                .foregroundStyle(isSelected ? option.2 : .secondary)
                                        }
                                        
                                        Text(option.1)
                                            .font(.caption2)
                                            .fontWeight(isSelected ? .bold : .medium)
                                            .foregroundStyle(isSelected ? .primary : .secondary)
                                    }
                                    .frame(width: 65)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 2)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .secondarySystemGroupedBackground)))
                .shadow(color: .black.opacity(0.02), radius: 8, y: 3)
                
                // Card 3: Date Calendar Picker
                VStack(spacing: 16) {
                    HStack(spacing: 10) {
                        Image(systemName: "calendar")
                            .font(.headline)
                            .foregroundStyle(.orange)
                        Text("Date of Record")
                            .font(.headline)
                        Spacer()
                    }
                    
                    DatePicker(
                        "Record Date",
                        selection: $travel.date,
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
                        Text(travel.date.toString(style: .long))
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .secondarySystemGroupedBackground)))
                .shadow(color: .black.opacity(0.02), radius: 8, y: 3)
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
    }
}

#Preview {
    EditView(travel: .constant(Travel()))
}
