//
//  TravelData.swift
//  Physical Presence Calculator
//
//  Created by Lehan Yang on 12/24/23.
//

import SwiftUI

class TravelData: ObservableObject {
    @Published var initDate: Date = TravelDate(date: "2020-01-01")!
    @Published var travels: [Travel] = [
        Travel(entry: true,
               port: "Greenside",
               transport: "ferry",
               date: TravelDate(date: "2020-06-01")!),
        Travel(entry: false,
               port: "Hapwich",
               transport: "car",
               date: TravelDate(date: "2020-01-01")!),
    ]
    
    func add(travel: Travel) {
        travels.append(travel)
        travels.sort() { $0.date < $1.date }
    }
    
    func remove(travel: Travel) {
        travels.removeAll { $0.id == travel.id }
    }
}

func TravelDate(date: String) -> Date? {
    let df = DateFormatter()
    df.locale = Locale(identifier: "en_US_POSIX")
    df.dateFormat = "yyyy-MM-dd"
    return df.date(from: date)
}
