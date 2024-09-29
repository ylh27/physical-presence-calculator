//
//  Compliance.swift
//  Physical Presence Calculator
//
//  Created by Lehan Yang on 9/24/24.
//

import Foundation

// TODO: implement exemptions

// calculate date
// date must be in CST without time stamp
func daysInCanada(travelData: TravelData, exemptionData: ExemptionData, referenceDate: Date) -> Int {
    
    var entry, exit: Date
    var tot = 0
    
    var startDate = Calendar.current.date(byAdding: .year, value: -5, to: referenceDate)
    if startDate! < travelData.initDate {
        startDate = travelData.initDate
    }
    
    entry = referenceDate
    exit = referenceDate
    
    for travel in travelData.travels {
        if travel.date > referenceDate {
            continue
        }
        
        if exit == startDate! {
            break
        }
        
        if travel.entry {
            if travel.date < startDate! {
                break
            }
            entry = travel.date;
        } else {
            if travel.date < startDate! {
                exit = startDate!
            } else {
                exit = travel.date
            }
        }
        
        if exit < entry {
            tot += Calendar.current.dateComponents([.day], from: exit, to: entry).day!
        }
    }
    
    return Calendar.current.dateComponents([.day], from: startDate!, to: referenceDate).day! - tot;
}

func dateToReturn(travelData: TravelData, exemptionData: ExemptionData) -> Date {
    
    var date = removeTimeStamp(fromDate: Date.now)
    let fiveYearCutoff = Calendar.current.date(byAdding: .year, value: 5, to: travelData.initDate)!

    if (date > fiveYearCutoff) {
        while daysInCanada(travelData: travelData, exemptionData: exemptionData, referenceDate: date) >= 730 {
            date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
            if date > Calendar.current.date(byAdding: .year, value: 5, to: travelData.travels[0].date)! {
                break
            }
        }
    } else {
        let daysNeeded = daysInCanada(travelData: travelData, exemptionData: exemptionData, referenceDate: date) - 730
        date = Calendar.current.date(byAdding: .day, value: daysNeeded, to: fiveYearCutoff)!
    }
    
    return date
}
