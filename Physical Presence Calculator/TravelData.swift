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
    
    private static func getEventsFileURL() throws -> URL {
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("travels.data")
    }
    
    func load() {
        do {
            let fileURL = try TravelData.getEventsFileURL()
            let data = try Data(contentsOf: fileURL)
            travels = try JSONDecoder().decode([Travel].self, from: data)
            print("Events loaded: \(travels.count)")
        } catch {
            print("Failed to load from file. Backup data used")
        }
    }
    
    func save() {
        do {
            let fileURL = try TravelData.getEventsFileURL()
            let data = try JSONEncoder().encode(travels)
            try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
            print("Travel list saved")
        } catch {
            print("Unable to save")
        }
    }
}

func TravelDate(date: String) -> Date? {
    let df = DateFormatter()
    df.locale = Locale(identifier: "en_US_POSIX")
    df.dateFormat = "yyyy-MM-dd"
    return df.date(from: date)
}
