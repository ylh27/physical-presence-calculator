//
//  Compliance.swift
//  Physical Presence Calculator
//
//  Created by Lehan Yang on 9/24/24.
//

import Foundation

// Exemptions are implemented using calendar day checking.

/// Calculates physical presence days in Canada within a rolling 5-year window.
func daysInCanada(travelData: TravelData, referenceDate: Date) -> Int {
    let calendar = Calendar.current
    let refDateStripped = referenceDate.strippedTime
    
    guard var startDate = calendar.date(byAdding: .year, value: -5, to: refDateStripped) else {
        return 0
    }
    
    if startDate < travelData.initDate {
        startDate = travelData.initDate
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
    
    var presenceDays = 0
    
    // Iterate through every single calendar day from startDate to refDateStripped (inclusive)
    var currentDay = startDate
    while currentDay <= refDateStripped {
        let currentDayStripped = currentDay.strippedTime
        
        // Check if there are any travel events on this day
        let eventsOnDay = sortedTravels.filter { $0.date.strippedTime == currentDayStripped }
        
        if !eventsOnDay.isEmpty {
            // Under CBSA guidelines, any part of a day spent in Canada counts as a full day of presence.
            // Since there is a travel event (arrival or departure) on this day, the user spent part of it in Canada.
            presenceDays += 1
        } else {
            // Find the most recent travel event before this day
            let priorEvents = sortedTravels.filter { $0.date.strippedTime < currentDayStripped }
            if let lastPriorEvent = priorEvents.last {
                if lastPriorEvent.entry {
                    // Last event was an arrival -> user is in Canada
                    presenceDays += 1
                } else {
                    // Last event was a departure -> user is outside Canada (absent)
                    // Check if this absence is exempt
                    let isExempt = travelData.exemptions.contains { exemption in
                        currentDayStripped >= exemption.startDate.strippedTime &&
                        currentDayStripped <= exemption.endDate.strippedTime
                    }
                    if isExempt {
                        presenceDays += 1
                    }
                }
            } else {
                // No prior travel events. By default, the user is in Canada starting from their PR initDate.
                presenceDays += 1
            }
        }
        
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDay) else {
            break
        }
        currentDay = nextDay
    }
    
    return presenceDays
}


/// Calculates the target date of compliance return, avoiding potential out of bounds crashes.
func dateToReturn(travelData: TravelData) -> Date {
    let calendar = Calendar.current
    var date = Date.now.strippedTime
    
    guard let fiveYearCutoff = calendar.date(byAdding: .year, value: 5, to: travelData.initDate) else {
        return date
    }
    
    // PR residency requires 730 days in Canada out of 5 years.
    let requiredPresenceDays = 730

    if date > fiveYearCutoff {
        guard let firstTravelDate = travelData.travels.first?.date else {
            return date
        }
        
        while daysInCanada(travelData: travelData, referenceDate: date) >= requiredPresenceDays {
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = nextDate
            
            if let limitDate = calendar.date(byAdding: .year, value: 5, to: firstTravelDate) {
                if date > limitDate {
                    break
                }
            } else {
                break
            }
        }
    } else {
        let daysNeeded = daysInCanada(travelData: travelData, referenceDate: date) - requiredPresenceDays
        date = calendar.date(byAdding: .day, value: daysNeeded, to: fiveYearCutoff) ?? fiveYearCutoff
    }
    
    return date
}
