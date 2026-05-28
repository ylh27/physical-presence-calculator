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
        XCTAssertEqual(days, 40)
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
        XCTAssertEqual(days, 30)
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
        XCTAssertEqual(days, expectedTotalDays)
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
