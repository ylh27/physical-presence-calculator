//
//  Travel.swift
//  Physical Presence Calculator
//
//  Created by Lehan Yang on 12/27/23.
//

import SwiftUI

struct Travel: Identifiable, Hashable, Codable {
    var id = UUID()
    var entry: Bool = false
    var port: String = "Montréal"
    var transport: String = "airplane"
    var date = TravelDate(date: "2020-01-01")!
    
    var symbol: String {
        if entry == true {
            return "figure.walk.departure"
        } else {
            return "figure.walk.arrival"
        }
    }
    
    var title: String {
        if entry == false {
            return "Departure at " + port
        } else {
            return "Entry at " + port
        }
    }
    
    mutating func setTransport(string: String) {
        transport = string
    }
}
