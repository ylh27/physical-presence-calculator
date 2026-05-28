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
    var reason = ""
}
