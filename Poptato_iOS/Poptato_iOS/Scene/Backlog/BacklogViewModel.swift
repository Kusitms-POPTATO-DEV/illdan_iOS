//
//  BacklogViewModel.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/23/24.
//

import SwiftUI
import Combine

class BacklogViewModel: ObservableObject {
    private let backlogRepository: BacklogRepository
    @Published var backlogList: Array<TodoItemModel> = []
    
    init(backlogRepository: BacklogRepository = BacklogRepositoryImpl()) {
        self.backlogRepository = backlogRepository
        Task {
            await fetchBacklogList()
        }
    }
    
    func createBacklog(_ item: String) async {
        do {
            let response = try await backlogRepository.createBacklog(request: CreateBacklogRequest(content: item))
            DispatchQueue.main.async {
                self.backlogList.insert(
                    TodoItemModel(todoId: response.todoId, content: item, bookmark: false, dDay: nil, deadline: nil),
                    at: 0
                )
            }
        } catch {
            DispatchQueue.main.async {
                print("Login error: \(error)")
            }
        }
    }
    
    private func fetchBacklogList() async {
        do {
            let response = try await backlogRepository.getBacklogList(page: 0, size: 100)
            DispatchQueue.main.async {
                self.backlogList = response.backlogs.map { item in
                    TodoItemModel(
                        todoId: item.todoId,
                        content: item.content,
                        bookmark: item.bookmark,
                        dDay: item.dDay,
                        deadline: item.deadline
                    )
                }
            }
        } catch {
            DispatchQueue.main.async {
                print("Error fetching backlog list: \(error)")
            }
        }
    }
    
    func deleteBacklog(todoId: Int) async {
        do {
            try await backlogRepository.deleteBacklog(todoId: todoId)
            DispatchQueue.main.async {
                self.backlogList.removeAll { $0.todoId == todoId }
            }
        } catch {
            DispatchQueue.main.async {
                print("Error delete backlog: \(error)")
            }
        }
    }
}
