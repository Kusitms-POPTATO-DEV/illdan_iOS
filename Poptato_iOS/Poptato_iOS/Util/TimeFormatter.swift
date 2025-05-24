//
//  TimeFormatter.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 2/1/25.
//

import Foundation

struct TimeFormatter {
    static func currentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    static func getCurrentMonthDay() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        return formatter.string(from: Date())
    }
    
    static func formatDate(date: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: date)
    }
}
