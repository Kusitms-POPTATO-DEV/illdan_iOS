//
//  AppStorageManager.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 2/1/25.
//

import Combine
import SwiftUI

struct AppStorageManager {
    private static let deadlineDateModeKey = "deadlineDateMode"
    
    static let deadlineDateModePublisher = CurrentValueSubject<Bool, Never>(UserDefaults.standard.bool(forKey: deadlineDateModeKey))
    
    static var deadlineDateMode: Bool {
        get {
            return deadlineDateModePublisher.value
        }
        set {
            UserDefaults.standard.set(newValue, forKey: deadlineDateModeKey)
            deadlineDateModePublisher.send(newValue)
        }
    }
}
