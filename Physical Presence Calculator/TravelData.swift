//
//  TravelData.swift
//  Physical Presence Calculator
//
//  Created by Lehan Yang on 12/24/23.
//

import Foundation
import OSLog

class TravelData: ObservableObject {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.physicalpresence.calculator", category: "TravelData")
    
    @Published var initDate: Date = Date.from(yyyymmdd: "2020-01-01")?.strippedTime ?? Date()
    @Published var travels: [Travel] = [
        Travel(entry: true,
               port: "Greenside",
               transport: "ferry",
               date: Date.from(yyyymmdd: "2020-06-01") ?? Date()),
        Travel(entry: false,
               port: "Hapwich",
               transport: "car",
               date: Date.from(yyyymmdd: "2020-01-01") ?? Date()),
    ]
    
    @MainActor
    func add(travel: Travel) {
        travels.append(travel)
        travels.sort { $0.date > $1.date } // decreasing order
    }
    
    @MainActor
    func remove(travel: Travel) {
        travels.removeAll { $0.id == travel.id }
    }
    
    private static func getTravelsFileURL() throws -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("travels.json")
    }
    
    private static func getDateFileURL() throws -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("initDate.json")
    }
    
    @MainActor
    func load() async {
        do {
            let fileURL = try TravelData.getTravelsFileURL()
            let loadedTravels = try await Task.detached(priority: .background) { () -> [Travel] in
                guard FileManager.default.fileExists(atPath: fileURL.path) else {
                    throw CocoaError(.fileReadNoSuchFile)
                }
                let data = try Data(contentsOf: fileURL)
                return try JSONDecoder().decode([Travel].self, from: data)
            }.value
            
            self.travels = loadedTravels
            Self.logger.info("Events loaded: \(loadedTravels.count)")
        } catch {
            Self.logger.warning("Failed to load travels from file: \(error.localizedDescription, privacy: .public). Backup data used.")
        }
    }
    
    @MainActor
    func save() async {
        let travelsToSave = self.travels
        do {
            let fileURL = try TravelData.getTravelsFileURL()
            try await Task.detached(priority: .background) {
                let data = try JSONEncoder().encode(travelsToSave)
                try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
            }.value
            Self.logger.info("Travel list saved successfully")
        } catch {
            Self.logger.error("Unable to save travels: \(error.localizedDescription, privacy: .public)")
        }
    }
    
    @MainActor
    func loadDate() async {
        do {
            let fileURL = try TravelData.getDateFileURL()
            let loadedDate = try await Task.detached(priority: .background) { () -> Date in
                guard FileManager.default.fileExists(atPath: fileURL.path) else {
                    throw CocoaError(.fileReadNoSuchFile)
                }
                let data = try Data(contentsOf: fileURL)
                return try JSONDecoder().decode(Date.self, from: data)
            }.value
            
            self.initDate = loadedDate
            Self.logger.info("Date loaded")
        } catch {
            Self.logger.warning("Failed to load date from file: \(error.localizedDescription, privacy: .public). Backup data used.")
        }
    }
    
    @MainActor
    func saveDate() async {
        let dateToSave = self.initDate
        do {
            let fileURL = try TravelData.getDateFileURL()
            try await Task.detached(priority: .background) {
                let data = try JSONEncoder().encode(dateToSave)
                try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
            }.value
            Self.logger.info("Date saved successfully")
        } catch {
            Self.logger.error("Unable to save date: \(error.localizedDescription, privacy: .public)")
        }
    }
    
    func daysSincePR() -> Int? {
        let diff = Calendar.current.dateComponents([.day], from: initDate, to: Date.now)
        return diff.day
    }
}
