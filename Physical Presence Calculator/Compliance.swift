//
//  Compliance.swift
//  Physical Presence Calculator
//
//  Created by Lehan Yang on 9/24/24.
//

import Foundation

// TODO: implement exemptions

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
    
    var entry = refDateStripped
    var exit = refDateStripped
    var tot = 0
    
    for travel in travelData.travels {
        let travelDate = travel.date.strippedTime
        if travelDate > refDateStripped {
            continue
        }
        
        if exit == startDate {
            break
        }
        
        if travel.entry {
            if travelDate < startDate {
                break
            }
            entry = travelDate
        } else {
            if travelDate < startDate {
                exit = startDate
            } else {
                exit = travelDate
            }
        }
        
        if exit < entry {
            if let days = calendar.dateComponents([.day], from: exit, to: entry).day {
                tot += days
            }
        }
    }
    
    let totalDays = calendar.dateComponents([.day], from: startDate, to: refDateStripped).day ?? 0
    return totalDays - tot
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
