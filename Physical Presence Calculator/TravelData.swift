//
//  TravelData.swift
//  Physical Presence Calculator
//
//  Created by Lehan Yang on 12/24/23.
//

import SwiftUI

class TravelData: ObservableObject {
    @Published var travels: [Travel] = [
        Travel(entry: true,
               port: "Greenside",
               transport: "boat",
               date: Date(timeIntervalSince1970: 1703678421)),
        Travel(entry: false,
               port: "Hapwich",
               transport: "car",
               date: Date(timeIntervalSince1970: 1703678421))
    ]
    
    func add(travel: Travel) {
        travels.append(travel)
        travels.sort() { $0.date < $1.date }
    }
    
    func remove(travel: Travel) {
        travels.removeAll { $0.id == travel.id }
    }
}
