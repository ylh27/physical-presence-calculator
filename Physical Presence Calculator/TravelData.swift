//
//  TravelData.swift
//  Physical Presence Calculator
//
//  Created by Lehan Yang on 12/24/23.
//

import Foundation

func removeTimeStamp(fromDate: Date) -> Date {
    guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: fromDate)) else {
        fatalError("Failed to strip time from Date object")
    }
    return date
}

class TravelData: ObservableObject {
    @Published var initDate: Date = removeTimeStamp(fromDate: TravelDate(date: "2020-01-01")!)
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
        travels.sort() { $0.date > $1.date }    // decreasing order
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
    
    func daysSincePR() -> Int? {
        let diff = Calendar.current.dateComponents([.day], from: initDate, to: Date.now)
        return diff.day
    }
}

func TravelDate(date: String) -> Date? {
    let df = DateFormatter()
    df.locale = Locale(identifier: "en_US_POSIX")
    df.timeZone = TimeZone(identifier: "Canada/Central")
    df.dateFormat = "yyyy-MM-dd"
    return removeTimeStamp(fromDate: df.date(from: date)!)
}

// convert date to string in CST with time omitted
func DateToString(date: Date, style: Date.FormatStyle.DateStyle) -> String {
    var f = Date.FormatStyle(date: style, time: .omitted)
    f.timeZone = TimeZone(identifier: "Canada/Central")!
    return date.formatted(f)
}
