//
//  BacklogListModel.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/23/24.
//

import Foundation
import SwiftUI

struct BacklogListModel: Codable {
    let totalCount: Int
    let backlogs: Array<TodoItemModel>
    let totalPageCount: Int
}
