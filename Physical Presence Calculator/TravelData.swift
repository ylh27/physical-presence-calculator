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
    
    private static func getTravelsFileURL() throws -> URL {
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("travels.data")
    }
    
    private static func getDateFileURL() throws -> URL {
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("initDate.data")
    }
    
    func load() {
        do {
            let fileURL = try TravelData.getTravelsFileURL()
            let data = try Data(contentsOf: fileURL)
            travels = try JSONDecoder().decode([Travel].self, from: data)
            print("Events loaded: \(travels.count)")
        } catch {
            print("Failed to load from file. Backup data used")
        }
    }
    
    func save() {
        do {
            let fileURL = try TravelData.getTravelsFileURL()
            let data = try JSONEncoder().encode(travels)
            try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
            print("Travel list saved")
        } catch {
            print("Unable to save")
        }
    }
    
    func loadDate() {
        do {
            let fileURL = try TravelData.getDateFileURL()
            let data = try Data(contentsOf: fileURL)
            initDate = try JSONDecoder().decode(Date.self, from: data)
            print("Date loaded")
        } catch {
            print("Failed to load from file. Backup data used")
        }
    }
    
    func saveDate() {
        do {
            let fileURL = try TravelData.getDateFileURL()
            let data = try JSONEncoder().encode(initDate)
            try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
            print("Date saved")
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
