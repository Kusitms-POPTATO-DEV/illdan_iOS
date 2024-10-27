//
//  TodayListResponse.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/27/24.
//

struct TodayListResponse: Codable {
    let date: String
    var todays: Array<TodayItemModel>
    let totalPageCount: Int
}
