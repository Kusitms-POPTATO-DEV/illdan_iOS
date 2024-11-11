//
//  YesterdayTodoViewModel.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/11/24.
//

import SwiftUI

class YesterdayTodoViewModel: ObservableObject {
    private var todoRepository: TodoRepository
    @Published var yesterdayList: Array<YesterdayItemModel> = []
    
    init(todoRepository: TodoRepository = TodoRepositoryImpl()) {
        self.todoRepository = todoRepository
    }
    
    func getYesterdayList(page: Int, size: Int) async {
        do {
            let response = try await todoRepository.getYesterdayList(page: page, size: size)
            await MainActor.run {
                self.yesterdayList = response.yesterdays
            }
        } catch {
            print("Error getYesterdayList: \(error)")
        }
    }
}
