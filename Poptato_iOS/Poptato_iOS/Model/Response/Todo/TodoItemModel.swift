//
//  TodoItemModel.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/23/24.
//

import Foundation
import SwiftUI

struct TodoItemModel: Codable {
    var todoId: Int
    var content: String
    var isBookmark: Bool
    var isRepeat: Bool
    var dDay: Int?
    var deadline: String?
    var categoryId: Int?
    var categoryName: String?
    var imageUrl: String?
    var time: String?
    var isRoutine: Bool = false
    var routineDays: [String] = []
}

extension TodoItemModel {
    static var placeholder: TodoItemModel {
        return TodoItemModel(
            todoId: -1,
            content: "",
            isBookmark: false,
            isRepeat: false,
            isRoutine: false,
            routineDays: []
        )
    }
}

extension TodoItemModel {
    var timeInfo: TimeInfo? {
        if let time {
            return TimeFormatter.convertStringToTimeInfo(time: time)
        } else {
            return nil
        }
    }
    
    var timeString: String {
        if let info = timeInfo {
            return String(format: "%@ %02d:%02d", info.meridiem, info.hour, info.minute)
        } else {
            return ""
        }
    }
}

extension TodoItemModel {
    var routineDayIndexes: Set<Int> {
        let dayToIndexMap: [String: Int] = [
            "월": 0,
            "화": 1,
            "수": 2,
            "목": 3,
            "금": 4,
            "토": 5,
            "일": 6
        ]
        
        return Set(routineDays.compactMap { dayToIndexMap[$0] })
    }
}
