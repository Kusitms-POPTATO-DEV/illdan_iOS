//
//  BacklogListResponse.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/26/24.
//

struct BacklogListResponse: Codable {
    let totalCount: Int
    let backlogs: Array<TodoItemModel>
    let totalPageCount: Int
}
