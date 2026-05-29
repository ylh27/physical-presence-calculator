//
//  EditExemptionView.swift
//  Physical Presence Calculator
//
//  Created by Antigravity on 2026-05-28.
//

import SwiftUI

struct EditExemptionView: View {
    @Binding var exemption: Exemption
    
    @State private var selectedReasonOption = ""
    @State private var customReason = ""
    
    let standardReasons = [
        "Accompanying a Canadian Citizen (Spouse/Partner/Parent)",
        "Employment Abroad by Canadian Business/Public Service",
        "Accompanying PR Employed by Canadian Business"
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Card 1: Exemption Period
                VStack(spacing: 16) {
                    HStack(spacing: 10) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.headline)
                            .foregroundStyle(.green)
                        Text("Exemption Period")
                            .font(.headline)
                        Spacer()
                    }
                    
                    VStack(spacing: 12) {
                        DatePicker(
                            "Start Date",
                            selection: $exemption.startDate,
                            displayedComponents: [.date]
                        )
                        .environment(\.timeZone, TimeZone(identifier: "Canada/Central") ?? TimeZone.current)
                        
                        Divider()
                        
                        DatePicker(
                            "End Date",
                            selection: $exemption.endDate,
                            displayedComponents: [.date]
                        )
                        .environment(\.timeZone, TimeZone(identifier: "Canada/Central") ?? TimeZone.current)
                    }
                    .padding(.vertical, 8)
                    
                    Divider()
                    
                    // Duration counter
                    HStack {
                        Text("Computed Duration:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.caption2)
                            Text("\(exemption.durationInDays) Days")
                                .font(.subheadline)
                                .fontWeight(.bold)
                        }
                        .foregroundStyle(.green)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color.green.opacity(0.1)))
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .secondarySystemGroupedBackground)))
                .shadow(color: .black.opacity(0.02), radius: 8, y: 3)
                
                // Card 2: Exemption Reason
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 10) {
                        Image(systemName: "doc.plaintext.fill")
                            .font(.headline)
                            .foregroundStyle(.purple)
                        Text("Reason for Exemption")
                            .font(.headline)
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Exemption Category / Rule")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                        
                        Picker("Rule / Reason", selection: $selectedReasonOption) {
                            ForEach(standardReasons, id: \.self) { reason in
                                Text(reason).tag(reason)
                            }
                            Text("Other / Custom Reason").tag("Other")
                        }
                        .pickerStyle(.menu)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(uiColor: .systemGroupedBackground)))
                    }
                    
                    if selectedReasonOption == "Other" {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Specify Reason Details")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                            
                            TextField("Enter custom reason description", text: $customReason)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color(uiColor: .systemGroupedBackground)))
                                .font(.body)
                                .autocorrectionDisabled()
                        }
                    }
                    
                    Divider()
                    
                    // Information box (IRPA warning / section 28)
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                            .padding(.top, 1)
                        
                        Text("Under Section 28 of the IRPA, these specific periods spent outside Canada count as physical presence in Canada.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.05)))
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(Color(uiColor: .secondarySystemGroupedBackground)))
                .shadow(color: .black.opacity(0.02), radius: 8, y: 3)
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .onAppear {
            if standardReasons.contains(exemption.reason) {
                selectedReasonOption = exemption.reason
            } else {
                selectedReasonOption = "Other"
                customReason = exemption.reason
            }
        }
        .onChange(of: selectedReasonOption) { _, newValue in
            if newValue != "Other" {
                exemption.reason = newValue
            } else {
                exemption.reason = customReason
            }
        }
        .onChange(of: customReason) { _, newValue in
            if selectedReasonOption == "Other" {
                exemption.reason = newValue
            }
        }
    }
}

#Preview {
    EditExemptionView(exemption: .constant(Exemption()))
}
