//
//  HistoryListModel.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/18/24.
//

struct HistoryListModel: Codable {
    let histories: [HistoryListItemModel]
    let totalPageCount: Int
}
