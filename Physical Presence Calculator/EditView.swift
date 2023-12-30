//
//  EditView.swift
//  Physical Presence Calculator
//
//  Created by Lehan Yang on 12/27/23.
//

import SwiftUI

struct EditView: View {
    @Binding var travel: Travel
    
    var body: some View {
        List {
            TextField("Port", text: $travel.port)
            Picker("Entry/Exit", selection: $travel.entry) {
                Text("Arrival").tag(true)
                Text("Departure").tag(false)
            }
            //Text(String(travel.entry))
            Picker("Transportation", selection: $travel.transport) {
                Text("Airplane").tag("airplane")
                Text("Train").tag("tram")
                Text("Boat").tag("ferry")
                Text("Bus").tag("bus")
                Text("Car").tag("car")
            }
            //Text(travel.transport)
            DatePicker(
                "Date",
                selection: $travel.date,
                displayedComponents: [.date]
            )
        }
    }
}

#Preview {
    EditView(travel: .constant(Travel()))
}
