//
//  BacklogViewModel.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/23/24.
//

import SwiftUI
import Combine

class BacklogViewModel: ObservableObject {
    @Published var backlogList: Array<TodoItemModel> = []
    
    func createBacklog(_ item: String) {
        let newItem = TodoItemModel(
            todoId: Int.random(in: 1...100000000),
            content: item,
            isBookmark: false,
            dDay: nil,
            deadline: nil
        )
        backlogList.append(newItem)
    }
}
