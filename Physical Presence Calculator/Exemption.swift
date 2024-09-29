//
//  Exemption.swift
//  Physical Presence Calculator
//
//  Created by Lehan Yang on 9/24/24.
//

import Foundation

class ExemptionData: ObservableObject {
    
}

struct Exemption: Identifiable, Hashable, Codable {
    var id = UUID()
    var startDate = TravelDate(date: "2020-01-01")
    var endDate = TravelDate(date: "2020-12-01")
    var reason = ""
}
