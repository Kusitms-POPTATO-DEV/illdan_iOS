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
    private let todoRepository: TodoRepository
    @Published var backlogList: Array<TodoItemModel> = []
    @Published var activeItemId: Int? = nil
    
    init(
        backlogRepository: BacklogRepository = BacklogRepositoryImpl(),
        todoRepository: TodoRepository = TodoRepositoryImpl()
    ) {
        self.backlogRepository = backlogRepository
        self.todoRepository = todoRepository
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
    
    func fetchBacklogList() async {
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
    
    func editBacklog(todoId: Int, content: String) async {
        do {
            try await backlogRepository.editBacklog(todoId: todoId, content: content)
        } catch {
            DispatchQueue.main.async {
                print("Error edit backlog: \(error)")
            }
        }
    }
    
    func swipeBacklog(todoId: Int) async {
        do {
            try await todoRepository.swipeTodo(request: TodoIdModel(todoId: todoId))
        } catch {
            DispatchQueue.main.async {
                print("Error swipe backlog: \(error)")
            }
        }
    }
}
