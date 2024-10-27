//
//  TodayItemModel.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/27/24.
//

struct TodayItemModel: Codable {
    let todoId: Int
    var content: String
    var todayStatus: String
    let bookmark: Bool
    let dDay: Int?
    let deadline: String?
}
