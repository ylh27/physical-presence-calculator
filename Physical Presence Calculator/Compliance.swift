//
//  Compliance.swift
//  Physical Presence Calculator
//
//  Created by Lehan Yang on 9/24/24.
//

import Foundation

enum TrackingGoal: String, CaseIterable, Identifiable, Codable {
    case pr = "PR Status"
    case citizenship = "Citizenship"
    var id: String { self.rawValue }
    
    var targetDays: Int {
        self == .pr ? 730 : 1095
    }
}

// Exemptions are implemented using calendar day checking.

/// Calculates physical presence days in Canada within a rolling 5-year window.
func daysInCanada(travelData: TravelData, referenceDate: Date, goal: TrackingGoal = .citizenship) -> Int {
    let calendar = Calendar.current
    let refDateStripped = referenceDate.strippedTime
    
    guard var startDate = calendar.date(byAdding: .year, value: -5, to: refDateStripped) else {
        return 0
    }
    
    // Determine the absolute earliest date we can track based on the goal
    let lowerLimitDate: Date
    if goal == .citizenship && travelData.wasTemporaryResident {
        // Under IRCC guidelines for Citizenship, pre-PR temporary resident time counts,
        // so we start tracking from the tempResidentDate (if enabled).
        lowerLimitDate = travelData.tempResidentDate.strippedTime
    } else {
        // For PR Status, pre-PR time does not count.
        lowerLimitDate = travelData.initDate.strippedTime
    }
    
    if startDate < lowerLimitDate {
        startDate = lowerLimitDate
    }
    
    if startDate > refDateStripped {
        return 0
    }
    
    // Sort travels in ascending order (earliest first).
    // For same-day travels, departures come before entries, so the final state on that day is in-Canada.
    let sortedTravels = travelData.travels.sorted { t1, t2 in
        if t1.date.strippedTime == t2.date.strippedTime {
            return !t1.entry && t2.entry
        }
        return t1.date < t2.date
    }
    
    var prePRPresenceDays = 0
    var postPRPresenceDays = 0
    
    // Iterate through every single calendar day from startDate to refDateStripped (inclusive)
    var currentDay = startDate
    while currentDay <= refDateStripped {
        let currentDayStripped = currentDay.strippedTime
        let isPrePRDay = currentDayStripped < travelData.initDate.strippedTime
        
        let eventsOnDay = sortedTravels.filter { $0.date.strippedTime == currentDayStripped }
        var dayIsPresent = false
        
        if currentDayStripped > Date.now.strippedTime {
            // Simulating the future: assume outside Canada (absent) starting tomorrow, unless exempt.
            let isExempt = travelData.exemptions.contains { exemption in
                currentDayStripped >= exemption.startDate.strippedTime &&
                currentDayStripped <= exemption.endDate.strippedTime
            }
            if isExempt {
                dayIsPresent = true
            }
        } else if !eventsOnDay.isEmpty {
            // Under CBSA guidelines, any part of a day spent in Canada counts as a full day of presence.
            // Since there is a travel event (arrival or departure) on this day, the user spent part of it in Canada.
            dayIsPresent = true
        } else {
            // Find the most recent travel event before this day
            let priorEvents = sortedTravels.filter { $0.date.strippedTime < currentDayStripped }
            if let lastPriorEvent = priorEvents.last {
                if lastPriorEvent.entry {
                    // Last event was an arrival -> user is in Canada
                    dayIsPresent = true
                } else {
                    // Last event was a departure -> user is outside Canada (absent)
                    // Check if this absence is exempt
                    let isExempt = travelData.exemptions.contains { exemption in
                        currentDayStripped >= exemption.startDate.strippedTime &&
                        currentDayStripped <= exemption.endDate.strippedTime
                    }
                    if isExempt {
                        dayIsPresent = true
                    }
                }
            } else {
                // No prior travel events. By default, the user is in Canada starting from their active window's start.
                dayIsPresent = true
            }
        }
        
        if dayIsPresent {
            if isPrePRDay {
                prePRPresenceDays += 1
            } else {
                postPRPresenceDays += 1
            }
        }
        
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDay) else {
            break
        }
        currentDay = nextDay
    }
    
    let prePRCredit = Double(prePRPresenceDays) * 0.5
    let cappedPrePRCredit = min(365.0, prePRCredit)
    
    return postPRPresenceDays + Int(cappedPrePRCredit)
}


/// Calculates the target date of compliance return, avoiding potential out of bounds crashes.
func dateToReturn(travelData: TravelData) -> Date {
    let calendar = Calendar.current
    let nowStripped = Date.now.strippedTime
    
    guard let fiveYearCutoff = calendar.date(byAdding: .year, value: 5, to: travelData.initDate) else {
        return nowStripped
    }
    
    let requiredPresenceDays = 730
    
    // Calculate presence today specifically for the PR goal
    let currentPresence = daysInCanada(travelData: travelData, referenceDate: nowStripped, goal: .pr)
    
    if currentPresence >= requiredPresenceDays {
        // Requirement is met! Find the first day they become non-compliant in the future.
        // We start searching from either 'nowStripped' or 'fiveYearCutoff' (whichever is later).
        var date = nowStripped > fiveYearCutoff ? nowStripped : fiveYearCutoff
        
        let limitDate = calendar.date(byAdding: .year, value: 5, to: date) ?? date
        
        while daysInCanada(travelData: travelData, referenceDate: date, goal: .pr) >= requiredPresenceDays {
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = nextDate
            
            if date > limitDate {
                break
            }
        }
        return date
    } else {
        // Requirement not met!
        if nowStripped > fiveYearCutoff {
            // Already past 5 years and not compliant.
            return nowStripped
        } else {
            // Within first 5 years: return in time to accumulate 730 days by fiveYearCutoff.
            let daysNeeded = currentPresence - requiredPresenceDays // This is negative
            return calendar.date(byAdding: .day, value: daysNeeded, to: fiveYearCutoff) ?? fiveYearCutoff
        }
    }
}
