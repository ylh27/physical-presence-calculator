//
//  Travel.swift
//  Physical Presence Calculator
//
//  Created by Lehan Yang on 12/27/23.
//

import Foundation

struct Travel: Identifiable, Hashable, Codable {
    var id = UUID()
    var entry = false
    var port = "Montréal"
    var transport = "airplane"
    var date = Date.from(yyyymmdd: "2020-01-01") ?? Date()
    
    var symbol: String {
        if entry {
            return "figure.walk.departure"
        } else {
            return "figure.walk.arrival"
        }
    }
    
    var title: String {
        if !entry {
            return "Departure at " + port
        } else {
            return "Entry at " + port
        }
    }
    
    mutating func setTransport(string: String) {
        transport = string
    }
}
