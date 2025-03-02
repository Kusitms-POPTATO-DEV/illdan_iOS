//
//  YesterdayTodoViewModel.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/11/24.
//

import SwiftUI

class YesterdayTodoViewModel: ObservableObject {
    private var todoRepository: TodoRepository
    private var completionList: Array<Int> = []
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
    
    func completeYesterdayTodo() async {
        do {
            try await todoRepository.updateYesterdayCompletion(todoIdsRequest: TodoIdsRequest(todoIds: completionList))
            
            await MainActor.run {
                AppStorageManager.hasSeenYesterday = true
                completionList.removeAll()
            }
            
            await MainActor.run {
                NotificationCenter.default.post(name: .yesterdayTodoCompleted, object: nil)
            }
        } catch {
            print("Error CompleteYesterdayTodo: \(error)")
        }
    }
    
    func addCompletionList(todoId: Int) {
        if let index = completionList.firstIndex(of: todoId) {
            completionList.remove(at: index)
        } else {
            completionList.append(todoId)
        }
    }
}
