//
//  YesterdayListResponse.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/10/24.
//

struct YesterdayListResponse: Codable {
    let yesterdays: Array<YesterdayItemModel>
    let totalPageCount: Int
}
