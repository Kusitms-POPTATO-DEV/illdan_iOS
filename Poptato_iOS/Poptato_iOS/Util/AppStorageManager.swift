//
//  AppStorageManager.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 2/1/25.
//

import SwiftUI

struct AppStorageManager {
    private static let hasSeenYesterdayKey = "hasSeenYesterdayView"
    private static let lastUpdatedDateKey = "lastUpdatedDate"
    private static let deadlineDateModeKey = "deadlineDateMode"
    
    static var hasSeenYesterday: Bool {
        get {
            checkAndResetIfNewDay()
            return UserDefaults.standard.bool(forKey: hasSeenYesterdayKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasSeenYesterdayKey)
            UserDefaults.standard.set(TimeFormatter.currentDateString(), forKey: lastUpdatedDateKey)
        }
    }
    
    private static func checkAndResetIfNewDay() {
        let lastUpdatedDate = UserDefaults.standard.string(forKey: lastUpdatedDateKey) ?? ""
        let today = TimeFormatter.currentDateString()

        if lastUpdatedDate != today {
            UserDefaults.standard.set(false, forKey: hasSeenYesterdayKey)
            UserDefaults.standard.set(today, forKey: lastUpdatedDateKey)
        }
    }
    
    static var deadlineDateMode: Bool {
        get {
            return UserDefaults.standard.bool(forKey: deadlineDateModeKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: deadlineDateModeKey)
        }
    }
}
