//
//  TodoItemModel.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/23/24.
//

import Foundation
import SwiftUI

struct TodoItemModel: Codable {
    let todoId: Int
    let content: String
    let isBookmark: Bool
    let dDay: Int?
    let deadline: String?
}
