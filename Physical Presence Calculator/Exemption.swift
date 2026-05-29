//
//  Exemption.swift
//  Physical Presence Calculator
//
//  Created by Lehan Yang on 9/24/24.
//

import Foundation

struct Exemption: Identifiable, Hashable, Codable {
    var id = UUID()
    var startDate = Date.from(yyyymmdd: "2020-01-01") ?? Date()
    var endDate = Date.from(yyyymmdd: "2020-12-01") ?? Date()
    var reason = "Accompanying a Canadian Citizen (Spouse/Partner/Parent)"
    
    var symbol: String {
        if reason.contains("Citizen") {
            return "person.2.fill"
        } else if reason.contains("Business") || reason.contains("Employment") || reason.contains("Employed") {
            return "briefcase.fill"
        } else {
            return "text.badge.checkmark"
        }
    }
    
    var durationInDays: Int {
        let calendar = Calendar.current
        let start = startDate.strippedTime
        let end = endDate.strippedTime
        if start > end { return 0 }
        return (calendar.dateComponents([.day], from: start, to: end).day ?? 0) + 1
    }
}
