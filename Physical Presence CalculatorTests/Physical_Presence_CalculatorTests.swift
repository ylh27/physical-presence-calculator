//
//  Physical_Presence_CalculatorTests.swift
//  Physical Presence CalculatorTests
//
//  Created by Lehan Yang on 12/24/23.
//

import XCTest
@testable import Physical_Presence_Calculator

final class Physical_Presence_CalculatorTests: XCTestCase {
    
    var travelData: TravelData!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        travelData = TravelData()
        travelData.travels = []
    }
    
    override func tearDownWithError() throws {
        travelData = nil
        try super.tearDownWithError()
    }
    
    func testDateParsingAndFormatting() {
        let validDate = Date.from(yyyymmdd: "2024-05-28")
        XCTAssertNotNil(validDate)
        
        let invalidDate = Date.from(yyyymmdd: "not-a-date")
        XCTAssertNil(invalidDate)
        
        let formattedString = validDate?.toString(style: .numeric)
        XCTAssertNotNil(formattedString)
    }
    
    func testDaysInCanadaWithNoTravels() {
        let calendar = Calendar.current
        guard let prSince = calendar.date(byAdding: .day, value: -30, to: Date.now.strippedTime) else {
            XCTFail("Failed to generate test date")
            return
        }
        travelData.initDate = prSince
        
        let days = daysInCanada(travelData: travelData, referenceDate: Date.now)
        XCTAssertEqual(days, 30)
    }
    
    func testDaysInCanadaWithSingleDepartureAndArrival() {
        let calendar = Calendar.current
        guard let prSince = calendar.date(byAdding: .day, value: -60, to: Date.now.strippedTime),
              let departureDate = calendar.date(byAdding: .day, value: -40, to: Date.now.strippedTime),
              let arrivalDate = calendar.date(byAdding: .day, value: -20, to: Date.now.strippedTime) else {
            XCTFail("Failed to generate test dates")
            return
        }
        travelData.initDate = prSince
        
        travelData.travels = [
            Travel(entry: true, port: "Montreal", transport: "airplane", date: arrivalDate),
            Travel(entry: false, port: "Montreal", transport: "airplane", date: departureDate)
        ]
        
        let days = daysInCanada(travelData: travelData, referenceDate: Date.now)
        // Under inclusive calendar counting, total days is 61.
        // Absences are day -39 to -21 inclusive (19 days).
        // Total present days = 61 - 19 = 42.
        XCTAssertEqual(days, 42)
    }
    
    func testDaysInCanadaSameDayTravel() {
        let calendar = Calendar.current
        guard let prSince = calendar.date(byAdding: .day, value: -30, to: Date.now.strippedTime),
              let sameDay = calendar.date(byAdding: .day, value: -15, to: Date.now.strippedTime) else {
            XCTFail("Failed to generate test dates")
            return
        }
        travelData.initDate = prSince
        
        travelData.travels = [
            Travel(entry: true, port: "Montreal", transport: "car", date: sameDay),
            Travel(entry: false, port: "Montreal", transport: "car", date: sameDay)
        ]
        
        let days = daysInCanada(travelData: travelData, referenceDate: Date.now)
        // Inclusive calendar count from -30 to 0 is 31 days.
        XCTAssertEqual(days, 31)
    }
    
    func testDaysInCanadaOutSideRollingWindow() {
        let calendar = Calendar.current
        guard let prSince = calendar.date(byAdding: .year, value: -6, to: Date.now.strippedTime),
              let oldDeparture = calendar.date(byAdding: .month, value: -66, to: Date.now.strippedTime),
              let oldArrival = calendar.date(byAdding: .month, value: -62, to: Date.now.strippedTime) else {
            XCTFail("Failed to generate test dates")
            return
        }
        travelData.initDate = prSince
        
        travelData.travels = [
            Travel(entry: true, port: "Montreal", transport: "airplane", date: oldArrival),
            Travel(entry: false, port: "Montreal", transport: "airplane", date: oldDeparture)
        ]
        
        guard let fiveYearsAgo = calendar.date(byAdding: .year, value: -5, to: Date.now.strippedTime),
              let expectedTotalDays = calendar.dateComponents([.day], from: fiveYearsAgo, to: Date.now.strippedTime).day else {
            XCTFail("Failed to compute expected days")
            return
        }
        
        let days = daysInCanada(travelData: travelData, referenceDate: Date.now)
        XCTAssertEqual(days, expectedTotalDays + 1)
    }
    
    func testDaysInCanadaNextDayTravel() {
        let calendar = Calendar.current
        guard let prSince = calendar.date(byAdding: .day, value: -30, to: Date.now.strippedTime),
              let departureDate = calendar.date(byAdding: .day, value: -15, to: Date.now.strippedTime),
              let arrivalDate = calendar.date(byAdding: .day, value: -14, to: Date.now.strippedTime) else {
            XCTFail("Failed to generate test dates")
            return
        }
        travelData.initDate = prSince
        
        travelData.travels = [
            Travel(entry: true, port: "Montreal", transport: "car", date: arrivalDate),
            Travel(entry: false, port: "Montreal", transport: "car", date: departureDate)
        ]
        
        let days = daysInCanada(travelData: travelData, referenceDate: Date.now)
        // Total period is 31 days. Depart Day X and Return Day X+1 should result in 0 absent days.
        XCTAssertEqual(days, 31)
    }

    func testDaysInCanadaWithExemptions() {
        let calendar = Calendar.current
        guard let prSince = calendar.date(byAdding: .day, value: -60, to: Date.now.strippedTime),
              let departureDate = calendar.date(byAdding: .day, value: -40, to: Date.now.strippedTime),
              let arrivalDate = calendar.date(byAdding: .day, value: -20, to: Date.now.strippedTime) else {
            XCTFail("Failed to generate test dates")
            return
        }
        travelData.initDate = prSince
        
        // Exemption covers 10 days of the 19 days absence (from -35 to -26 inclusive)
        guard let exemptStart = calendar.date(byAdding: .day, value: -35, to: Date.now.strippedTime),
              let exemptEnd = calendar.date(byAdding: .day, value: -26, to: Date.now.strippedTime) else {
            XCTFail("Failed to generate exemption dates")
            return
        }
        
        travelData.travels = [
            Travel(entry: true, port: "Montreal", transport: "airplane", date: arrivalDate),
            Travel(entry: false, port: "Montreal", transport: "airplane", date: departureDate)
        ]
        travelData.exemptions = [
            Exemption(startDate: exemptStart, endDate: exemptEnd, reason: "Spouse accompanying citizen")
        ]
        
        let days = daysInCanada(travelData: travelData, referenceDate: Date.now)
        // Period = 61 days. Under CBSA, normal presence = 42 days.
        // Exemption covers 10 days of absence, so present days should be 42 + 10 = 52.
        XCTAssertEqual(days, 52)
    }
    
    func testDaysInCanadaRobustToDuplicateExits() {
        let calendar = Calendar.current
        guard let prSince = calendar.date(byAdding: .day, value: -60, to: Date.now.strippedTime),
              let departure1 = calendar.date(byAdding: .day, value: -40, to: Date.now.strippedTime),
              let departure2 = calendar.date(byAdding: .day, value: -35, to: Date.now.strippedTime),
              let arrival = calendar.date(byAdding: .day, value: -20, to: Date.now.strippedTime) else {
            XCTFail("Failed to generate test dates")
            return
        }
        travelData.initDate = prSince
        
        // Consecutive departures without a matching entry (user typo/error)
        travelData.travels = [
            Travel(entry: true, port: "Montreal", transport: "airplane", date: arrival),
            Travel(entry: false, port: "Montreal", transport: "airplane", date: departure2),
            Travel(entry: false, port: "Montreal", transport: "airplane", date: departure1)
        ]
        
        let days = daysInCanada(travelData: travelData, referenceDate: Date.now)
        // With our calendar day state machine:
        // - From -60 to -40 (inclusive): 21 days present
        // - -40 is Departure -> present
        // - -39 to -36: absent (4 days)
        // - -35 is Departure -> present
        // - -34 to -21: absent (14 days)
        // - -20 to 0 (inclusive): 21 days present
        // Total absent days = 4 + 14 = 18 days.
        // Total present days = 61 - 18 = 43 days.
        XCTAssertEqual(days, 43)
    }
    
    func testDateToReturnGracefulHandlingOfEmptyTravels() {
        let calendar = Calendar.current
        guard let prSince = calendar.date(byAdding: .year, value: -6, to: Date.now.strippedTime) else {
            XCTFail("Failed to generate test date")
            return
        }
        travelData.initDate = prSince
        travelData.travels = []
        
        let targetDate = dateToReturn(travelData: travelData)
        XCTAssertGreaterThanOrEqual(targetDate, Date.now.strippedTime)
    }
}
