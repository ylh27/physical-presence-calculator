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
        List {
            Section(header: Text("Exemption Dates")) {
                DatePicker(
                    "Start Date",
                    selection: $exemption.startDate,
                    displayedComponents: [.date]
                )
                .environment(\.timeZone, TimeZone(identifier: "Canada/Central") ?? TimeZone.current)
                
                DatePicker(
                    "End Date",
                    selection: $exemption.endDate,
                    displayedComponents: [.date]
                )
                .environment(\.timeZone, TimeZone(identifier: "Canada/Central") ?? TimeZone.current)
            }
            
            Section(
                header: Text("Reason for Exemption"),
                footer: Text("Under Section 28 of the IRPA, these periods outside Canada count as physical presence in Canada.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            ) {
                Picker("Rule / Reason", selection: $selectedReasonOption) {
                    ForEach(standardReasons, id: \.self) { reason in
                        Text(reason).tag(reason)
                    }
                    Text("Other / Custom Reason").tag("Other")
                }
                .pickerStyle(.menu)
                
                if selectedReasonOption == "Other" {
                    TextField("Specify Custom Reason", text: $customReason)
                        .autocorrectionDisabled()
                }
            }
        }
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
