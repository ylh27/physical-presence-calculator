//
//  Date+Helpers.swift
//  Physical Presence Calculator
//
//  Created by Antigravity on 2026-05-28.
//

import Foundation

extension Date {
    /// Strips the time components (hour, minute, second) from the date, returning the start of the day.
    var strippedTime: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    /// Parses a date string in "yyyy-MM-dd" format using the Canada/Central timezone.
    /// Returns nil if the string is not in the correct format.
    static func from(yyyymmdd string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        if let timeZone = TimeZone(identifier: "Canada/Central") {
            formatter.timeZone = timeZone
        }
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: string) else {
            return nil
        }
        return date.strippedTime
    }
    
    /// Formats the date as a string using the Canada/Central timezone with time components omitted.
    func toString(style: Date.FormatStyle.DateStyle = .abbreviated) -> String {
        var format = Date.FormatStyle(date: style, time: .omitted)
        if let timeZone = TimeZone(identifier: "Canada/Central") {
            format.timeZone = timeZone
        }
        return self.formatted(format)
    }
}
