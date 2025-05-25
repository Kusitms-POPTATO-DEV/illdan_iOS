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
}

extension TodoItemModel {
    static var placeholder: TodoItemModel {
        return TodoItemModel(
            todoId: -1,
            content: "",
            isBookmark: false,
            isRepeat: false
        )
    }
}
