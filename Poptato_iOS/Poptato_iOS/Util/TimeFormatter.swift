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
    
    static func convertTimeInfoToString(info: TimeInfo) -> String {
        var hour24 = info.hour
        if info.meridiem == "오후" && info.hour != 12 {
            hour24 += 12
        } else if info.meridiem == "오전" && info.hour == 12 {
            hour24 = 0
        }
        return String(format: "%02d:%02d", hour24, info.minute)
    }
    
    static func convertStringToTimeInfo(time: String) -> TimeInfo? {
        let components = time.split(separator: ":")
        guard components.count >= 2,
              let hour24 = Int(components[0]),
              let minute = Int(components[1]) else {
            return nil
        }

        let meridiem: String
        let hour12: Int

        if hour24 == 0 {
            meridiem = "오전"
            hour12 = 12
        } else if hour24 < 12 {
            meridiem = "오전"
            hour12 = hour24
        } else if hour24 == 12 {
            meridiem = "오후"
            hour12 = 12
        } else {
            meridiem = "오후"
            hour12 = hour24 - 12
        }

        return TimeInfo(meridiem: meridiem, hour: hour12, minute: minute)
    }
}
