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
    let isBookmark: Bool
    let dday: Int?
    let deadline: String?
}
