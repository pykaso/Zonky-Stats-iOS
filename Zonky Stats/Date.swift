//
//  Date.swift
//  Zonky Stats
//
//  Created by lgergel on 16/11/2017.
//  Copyright © 2017 Lukas Gergel. All rights reserved.
//

import Foundation
extension Date {
    
    static func tzHome() -> TimeZone? {
        return TimeZone(abbreviation: TimeZone.current.identifier);
    }
    static func tzUTC() -> TimeZone? {
        return TimeZone(abbreviation: "UTC");
    }
    
    func toMonthBeg() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        dateFormatter.timeZone = Date.tzHome()
        return dateFormatter.string(from: self) + "-01"
    }
    
    func toISO() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        dateFormatter.timeZone = Date.tzHome()
        return dateFormatter.string(from: self)
    }
    
    static func from(_ year: Int, _ month: Int, _ day: Int) -> Date? {
        let gregorianCalendar = Calendar(identifier: .gregorian)
        let dateComponents = DateComponents(calendar: gregorianCalendar, timeZone: Date.tzHome(), year: year, month: month, day: day)
        return gregorianCalendar.date(from: dateComponents)
    }
    
    static func from(_ date: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = Date.tzHome()
        return dateFormatter.date(from:date)
    }
    
    func convertToLocal(fromTimeZone timeZone: TimeZone) -> Date? {
        let targetOffset = TimeInterval(timeZone.secondsFromGMT(for: self))
        let localOffset = TimeInterval(TimeZone.autoupdatingCurrent.secondsFromGMT(for: self))
        return self.addingTimeInterval(targetOffset - localOffset)
    }
    
    func setTime(hour: Int, min: Int, sec: Int) -> Date? {
        let x: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let cal = Calendar.current
        var components = cal.dateComponents(x, from: self)
        
        components.timeZone = Date.tzHome()
        components.hour = hour
        components.minute = min
        components.second = sec
        
        return cal.date(from: components)
    }
    
    func firstDay() -> Date? {
        let x: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let cal = Calendar.current
        var components = cal.dateComponents(x, from: self.resetTime()!)
        components.day = 1
        return cal.date(from: components)
    }
    
    func resetTime() -> Date? {
        return self.setTime(hour: 0, min: 0, sec: 0)
    }
}
