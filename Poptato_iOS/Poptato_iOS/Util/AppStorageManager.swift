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
    private static let todoCompletionCountKey = "todoCompletionCount"
    
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
    
    static let todoCompletionCountPublisher = CurrentValueSubject<Int, Never>(
        UserDefaults.standard.integer(forKey: todoCompletionCountKey)
    )
    
    static var todoCompletionCount: Int {
        get { todoCompletionCountPublisher.value }
        set {
            UserDefaults.standard.set(newValue, forKey: todoCompletionCountKey)
            todoCompletionCountPublisher.send(newValue)
        }
    }
    
    static func incrementTodoCompletionCount() {
        todoCompletionCount += 1
    }
    
    static func resetTodoCompletionCount() {
        todoCompletionCount = 0
    }
}
