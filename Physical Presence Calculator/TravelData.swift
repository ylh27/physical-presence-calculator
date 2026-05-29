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
    
    @Published var initDate: Date = Date().strippedTime
    @Published var travels: [Travel] = []
    @Published var exemptions: [Exemption] = []
    @Published var wasTemporaryResident: Bool = false
    @Published var tempResidentDate: Date = Date().strippedTime
    
    @MainActor
    func add(travel: Travel) {
        travels.append(travel)
        travels.sort { $0.date > $1.date } // decreasing order
    }
    
    @MainActor
    func remove(travel: Travel) {
        travels.removeAll { $0.id == travel.id }
    }
    
    @MainActor
    func addExemption(exemption: Exemption) {
        exemptions.append(exemption)
        exemptions.sort { $0.startDate > $1.startDate } // decreasing order
    }
    
    @MainActor
    func removeExemption(exemption: Exemption) {
        exemptions.removeAll { $0.id == exemption.id }
    }
    
    private static func getDirectoryURL() -> URL {
        if let ubiquityURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) {
            let documentsURL = ubiquityURL.appendingPathComponent("Documents")
            if !FileManager.default.fileExists(atPath: documentsURL.path) {
                do {
                    try FileManager.default.createDirectory(at: documentsURL, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    logger.error("Failed to create iCloud Documents directory: \(error.localizedDescription, privacy: .public)")
                }
            }
            return documentsURL
        } else {
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        }
    }
    
    private static func downloadUbiquitousFileIfNeeded(at url: URL) async {
        var isUbiquitous = false
        if FileManager.default.fileExists(atPath: url.path) {
            isUbiquitous = FileManager.default.isUbiquitousItem(at: url)
        } else {
            isUbiquitous = true
        }
        
        guard isUbiquitous else { return }
        
        do {
            let values = try url.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey])
            if let status = values.ubiquitousItemDownloadingStatus, status != .current {
                try FileManager.default.startDownloadingUbiquitousItem(at: url)
                for _ in 0..<50 { // Max 5 seconds
                    let currentValues = try url.resourceValues(forKeys: [.ubiquitousItemDownloadingStatusKey])
                    if currentValues.ubiquitousItemDownloadingStatus == .current {
                        logger.info("Successfully downloaded ubiquitous file: \(url.lastPathComponent)")
                        return
                    }
                    try await Task.sleep(nanoseconds: 100_000_000) // 100ms
                }
                logger.warning("iCloud download timed out for \(url.lastPathComponent)")
            }
        } catch {
            // First launch, or file doesn't exist yet
        }
    }
    
    private static func migrateLocalFilesToiCloudIfNeeded() {
        guard let ubiquityURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
            return
        }
        let iCloudDocsURL = ubiquityURL.appendingPathComponent("Documents")
        let localDocsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let fileNames = ["travels.json", "exemptions.json", "initDate.json", "tempResident.json"]
        
        if !FileManager.default.fileExists(atPath: iCloudDocsURL.path) {
            do {
                try FileManager.default.createDirectory(at: iCloudDocsURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                logger.error("Failed to create iCloud Documents directory for migration: \(error.localizedDescription, privacy: .public)")
                return
            }
        }
        
        for fileName in fileNames {
            let localURL = localDocsURL.appendingPathComponent(fileName)
            let iCloudURL = iCloudDocsURL.appendingPathComponent(fileName)
            
            if FileManager.default.fileExists(atPath: localURL.path) {
                if !FileManager.default.fileExists(atPath: iCloudURL.path) {
                    do {
                        try FileManager.default.copyItem(at: localURL, to: iCloudURL)
                        logger.info("Migrated \(fileName, privacy: .public) to iCloud.")
                    } catch {
                        logger.error("Failed to copy \(fileName, privacy: .public) to iCloud: \(error.localizedDescription, privacy: .public)")
                    }
                }
            }
        }
    }
    
    private static func getTravelsFileURL() throws -> URL {
        getDirectoryURL().appendingPathComponent("travels.json")
    }
    
    private static func getDateFileURL() throws -> URL {
        getDirectoryURL().appendingPathComponent("initDate.json")
    }
    
    private static func getExemptionsFileURL() throws -> URL {
        getDirectoryURL().appendingPathComponent("exemptions.json")
    }
    
    private static func getTempResidentFileURL() throws -> URL {
        getDirectoryURL().appendingPathComponent("tempResident.json")
    }
    
    @MainActor
    func load() async {
        await Task.detached(priority: .background) {
            Self.migrateLocalFilesToiCloudIfNeeded()
        }.value
        
        do {
            let fileURL = try TravelData.getTravelsFileURL()
            await TravelData.downloadUbiquitousFileIfNeeded(at: fileURL)
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
        
        do {
            let fileURL = try TravelData.getExemptionsFileURL()
            await TravelData.downloadUbiquitousFileIfNeeded(at: fileURL)
            let loadedExemptions = try await Task.detached(priority: .background) { () -> [Exemption] in
                guard FileManager.default.fileExists(atPath: fileURL.path) else {
                    throw CocoaError(.fileReadNoSuchFile)
                }
                let data = try Data(contentsOf: fileURL)
                return try JSONDecoder().decode([Exemption].self, from: data)
            }.value
            
            self.exemptions = loadedExemptions
            Self.logger.info("Exemptions loaded: \(loadedExemptions.count)")
        } catch {
            Self.logger.warning("Failed to load exemptions from file: \(error.localizedDescription, privacy: .public).")
        }
    }
    
    @MainActor
    func save() async {
        let travelsToSave = self.travels
        let exemptionsToSave = self.exemptions
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
        
        do {
            let fileURL = try TravelData.getExemptionsFileURL()
            try await Task.detached(priority: .background) {
                let data = try JSONEncoder().encode(exemptionsToSave)
                try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
            }.value
            Self.logger.info("Exemptions saved successfully")
        } catch {
            Self.logger.error("Unable to save exemptions: \(error.localizedDescription, privacy: .public)")
        }
    }
    
    @MainActor
    func loadDate() async {
        do {
            let fileURL = try TravelData.getDateFileURL()
            await TravelData.downloadUbiquitousFileIfNeeded(at: fileURL)
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
    
    @MainActor
    func loadTempResident() async {
        do {
            let fileURL = try TravelData.getTempResidentFileURL()
            await TravelData.downloadUbiquitousFileIfNeeded(at: fileURL)
            let loadedData = try await Task.detached(priority: .background) { () -> TempResidentData in
                guard FileManager.default.fileExists(atPath: fileURL.path) else {
                    throw CocoaError(.fileReadNoSuchFile)
                }
                let data = try Data(contentsOf: fileURL)
                return try JSONDecoder().decode(TempResidentData.self, from: data)
            }.value
            
            self.wasTemporaryResident = loadedData.wasTemporaryResident
            self.tempResidentDate = loadedData.tempResidentDate
            Self.logger.info("Temp resident loaded")
        } catch {
            Self.logger.warning("Failed to load temp resident from file: \(error.localizedDescription, privacy: .public). Backup data used.")
        }
    }
    
    @MainActor
    func saveTempResident() async {
        let dataToSave = TempResidentData(wasTemporaryResident: self.wasTemporaryResident, tempResidentDate: self.tempResidentDate)
        do {
            let fileURL = try TravelData.getTempResidentFileURL()
            try await Task.detached(priority: .background) {
                let data = try JSONEncoder().encode(dataToSave)
                try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
            }.value
            Self.logger.info("Temp resident saved successfully")
        } catch {
            Self.logger.error("Unable to save temp resident: \(error.localizedDescription, privacy: .public)")
        }
    }
}

struct TempResidentData: Codable {
    var wasTemporaryResident: Bool
    var tempResidentDate: Date
}
