//
//  TodayItemModel.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/27/24.
//

struct TodayItemModel: Codable {
    var todoId: Int
    var content: String
    var todayStatus: String
    var isBookmark: Bool
    var dDay: Int?
    var deadline: String?
    var isRepeat: Bool
    var imageUrl: String?
    var categoryName: String?
    var time: String?
    var isRoutine: Bool
    var routineDays: [String]
}

extension TodayItemModel {
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
