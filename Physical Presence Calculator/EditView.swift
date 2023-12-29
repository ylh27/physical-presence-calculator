//
//  EditView.swift
//  Physical Presence Calculator
//
//  Created by Lehan Yang on 12/27/23.
//

import SwiftUI

struct EditView: View {
    @Binding var travel: Travel
    
    enum Transport: String, CaseIterable, Identifiable {
        case airplane, tram, ferry, bus
        var id: Self { self }
    }
    @State private var transport: Transport = .airplane
    
    var body: some View {
        NavigationStack {
            List {
                TextField("Port", text: $travel.port)
                Picker("Entry/Exit", selection: $travel.entry) {
                    Text("Arrival").id(true)
                    Text("Departure").id(false)
                }
                Text(String(travel.entry))
                Picker("Transportation", selection: $travel.transport) {
                    Text("Airplane").id("airplane")
                    Text("Train").id("tram")
                }
                Text(travel.transport)
                DatePicker(
                    "Date",
                    selection: $travel.date,
                    displayedComponents: [.date]
                )
            }
            
            .navigationTitle(travel.title)
        }
    }
}

#Preview {
    EditView(travel: .constant(Travel()))
}
