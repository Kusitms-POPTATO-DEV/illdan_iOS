//
//  BacklogViewModel.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/23/24.
//

import SwiftUI
import Combine

class BacklogViewModel: ObservableObject {
    private var tempIdCounter = -1
    private let backlogRepository: BacklogRepository
    private let todoRepository: TodoRepository
    var isExistYesterdayTodo: Bool = false
    @Published var backlogList: Array<TodoItemModel> = []
    @Published var activeItemId: Int? = nil
    @Published var selectedTodoItem: TodoItemModel? = nil
    
    init(
        backlogRepository: BacklogRepository = BacklogRepositoryImpl(),
        todoRepository: TodoRepository = TodoRepositoryImpl()
    ) {
        self.backlogRepository = backlogRepository
        self.todoRepository = todoRepository
        Task {
            await fetchBacklogList()
            await getYesterdayList(page: 0, size: 1)
        }
    }
    
    func createBacklog(_ item: String) async {
        let temporaryId = tempIdCounter
        tempIdCounter -= 1
        
        let newItem = TodoItemModel(todoId: temporaryId, content: item, bookmark: false, dday: nil, deadline: nil)
        await MainActor.run {
            backlogList.insert(newItem, at: 0)
        }
        
        do {
            let response = try await backlogRepository.createBacklog(request: CreateBacklogRequest(content: item))
            await MainActor.run {
                if let index = backlogList.firstIndex(where: { $0.todoId == temporaryId }) {
                    backlogList[index].todoId = response.todoId
                }
            }
        } catch {
            await MainActor.run {
                backlogList.removeAll { $0.todoId == temporaryId }
            }
            print("Login error: \(error)")
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
                        dday: item.dday,
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
    
    func updateBookmark(todoId: Int) async {
        await MainActor.run { selectedTodoItem?.bookmark.toggle() }
        
        do {
            try await todoRepository.updateBookmark(todoId: todoId)
            
            await MainActor.run {
                if let index = backlogList.firstIndex(where: { $0.todoId == todoId }) {
                    backlogList[index].bookmark.toggle()
                }
            }
        } catch {
            DispatchQueue.main.async {
                print("Error updateBookmark: \(error)")
            }
        }
    }
    
    func updateDeadline(todoId: Int, deadline: String?) async {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        await MainActor.run { selectedTodoItem?.deadline = deadline }
        
        do {
            try await backlogRepository.updateDeadline(todoId: todoId, request: UpdateDeadlineRequest(deadline: deadline))
            await MainActor.run {
                if let index = backlogList.firstIndex(where: { $0.todoId == todoId }) {
                    backlogList[index].deadline = deadline
                    
                    if let deadline = deadline,
                        let parsedDate = dateFormatter.date(from: deadline) {
                        
                        let deadlineDate = Calendar.current.startOfDay(for: parsedDate)
                        let currentDate = Calendar.current.startOfDay(for: Date())
                        let calendar = Calendar.current

                        let components = calendar.dateComponents([.day], from: currentDate, to: deadlineDate)
                        if let daysDifference = components.day {
                            backlogList[index].dday = daysDifference
                            selectedTodoItem?.dday = daysDifference
                        }
                    } else {
                        backlogList[index].dday = nil
                        selectedTodoItem?.dday = nil
                    }
                }
            }
        } catch {
            print("Error updating deadline: \(error)")
        }
    }
    
    func updateSelectedItem(item: TodoItemModel?) {
        selectedTodoItem = item
    }
    
    func dragAndDrop() async {
        do {
            let todoIds = backlogList.map { $0.todoId }
            try await todoRepository.dragAndDrop(type: "BACKLOG", todoIds: todoIds)
        } catch {
            print("Error dragAndDrop: \(error)")
        }
    }
    
    func getYesterdayList(page: Int, size: Int) async {
        do {
            let response = try await todoRepository.getYesterdayList(page: page, size: size)
            await MainActor.run {
                if !response.yesterdays.isEmpty { isExistYesterdayTodo = true }
                else { isExistYesterdayTodo = false }
            }
        } catch {
            print("Error getYesterdayList: \(error)")
        }
    }
}
