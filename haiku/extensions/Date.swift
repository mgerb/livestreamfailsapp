//
//  Date.swift
//  haiku
//
//  Created by Mitchell Gerber on 1/21/19.
//  Copyright © 2019 Mitchell Gerber. All rights reserved.
//

import Foundation

extension Date {
    
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
    
    func offsetExtended(from date: Date) -> String {
        let y = years(from: date)
        let M = months(from: date)
        let w = weeks(from: date)
        let d = days(from: date)
        let h = hours(from: date)
        let m = minutes(from: date)
        let s = seconds(from: date)
        if y > 0 { return "\(y) year\(y > 1 ? "s" : "") ago" }
        if M > 0 { return "\(M) month\(M > 1 ? "s" : "") ago" }
        if w > 0 { return "\(w) week\(w > 1 ? "s" : "") ago" }
        if d > 0 { return "\(d) day\(d > 1 ? "s" : "") ago" }
        if h > 0 { return "\(h) hour\(h > 1 ? "s" : "") ago" }
        if m > 0 { return "\(m) minute\(m > 1 ? "s" : "") ago" }
        if s > 0 { return "\(s) second\(s > 1 ? "s" : "") ago" }
        return ""
    }
}
