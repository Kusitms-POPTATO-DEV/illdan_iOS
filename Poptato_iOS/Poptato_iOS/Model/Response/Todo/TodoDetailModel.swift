//
//  TodoDetailModel.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 12/11/24.
//

struct TodoDetailModel: Codable {
    let content: String
    let deadline: String?
    let categoryName: String?
    let emojiImageUrl: String?
    let isBookmark: Bool
    let isRepeat: Bool
}
