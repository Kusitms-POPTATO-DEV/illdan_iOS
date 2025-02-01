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
}
