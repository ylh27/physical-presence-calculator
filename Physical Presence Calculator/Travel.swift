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
    var transport: String = "plane"
    var date = Date.now
    
    var symbol: String {
        if entry == false {
            return "airplane.departure"
        } else {
            return "airplane.arrival"
        }
    }
    
    var title: String {
        if entry == false {
            return "Departure at " + port
        } else {
            return "Entry at " + port
        }
    }
}
