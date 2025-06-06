//
//  TodayViewModel.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/27/24.
//

import Combine
import SwiftUI
import Foundation

final class TodayViewModel: ObservableObject {
    @Published var todayList: Array<TodayItemModel> = []
    @Published var currentDate: String = ""
    @Published var selectedTodoItem: TodoItemModel? = nil
    @Published var categoryList: Array<CategoryModel> = []
    @Published var selectedCategoryIndex: Int = 0
    @Published var activeItemId: Int? = nil
    @Published var deadlineDateMode: Bool
    private var snapshotList: [TodayItemModel] = []
    private let todayRepository: TodayRepository
    private let todoRepository: TodoRepository
    private let backlogRepository: BacklogRepository
    private let categoryRepository: CategoryRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(
        todayRepository: TodayRepository = TodayRepositoryImpl(),
        todoRepository: TodoRepository = TodoRepositoryImpl(),
        backlogRepository: BacklogRepository = BacklogRepositoryImpl(),
        categoryRepository: CategoryRepository = CategoryRepositoryImpl()
    ) {
        self.todayRepository = todayRepository
        self.todoRepository = todoRepository
        self.backlogRepository = backlogRepository
        self.categoryRepository = categoryRepository
        self.deadlineDateMode = AppStorageManager.deadlineDateMode
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        currentDate = formatter.string(from: Date())
        
        CommonSettingsManager.shared.$deadlineDateMode
                    .sink { [weak self] newValue in
                        self?.deadlineDateMode = newValue
                    }
                    .store(in: &cancellables)
    }
    
    func getTodayList() async {
        do {
            let response = try await todayRepository.getTodayList(page: 0, size: 50)
            await MainActor.run {
                todayList = response.todays.map { item in
                    TodayItemModel(
                        todoId: item.todoId,
                        content: item.content,
                        todayStatus: item.todayStatus,
                        isBookmark: item.isBookmark,
                        dDay: item.dDay,
                        deadline: item.deadline,
                        isRepeat: item.isRepeat,
                        imageUrl: item.imageUrl,
                        categoryName: item.categoryName
                    )
                }
                self.snapshotList = self.todayList
            }
        } catch {
            DispatchQueue.main.async {
                print("Error getTodayList \(error)")
            }
        }
    }
    
    func swipeToday(todoId: Int) async {
        do {
            AnalyticsManager.shared.logEvent(AnalyticsEvent.back_tasks, parameters: ["task_id" : todoId])
            try await todoRepository.swipeTodo(request: TodoIdModel(todoId: todoId))
        } catch {
            print("Error swipe backlog: \(error)")
        }
    }
    
    func updateTodoCompletion(todoId: Int) async {
        let previousSnapshot = todayList
        
        do {
            AnalyticsManager.shared.logEvent(AnalyticsEvent.complete_task, parameters: ["task_id" : todoId])
            try await todoRepository.updateTodoCompletion(todoId: todoId)
            snapshotList = todayList
        } catch {
            await MainActor.run {
                print("Error update todocompletion: \(error)")
                todayList = previousSnapshot
            }
        }
    }
    
    func checkAllTodoCompleted() -> Bool {
        let result = todayList.allSatisfy { $0.todayStatus == "COMPLETED" }
        if result { AnalyticsManager.shared.logEvent(AnalyticsEvent.complete_all) }
        return result
    }
    
    func dragAndDrop() async {
        do {
            AnalyticsManager.shared.logEvent(AnalyticsEvent.drag_today)
            let todoIds = todayList.map{ $0.todoId }
            try await todoRepository.dragAndDrop(type: "TODAY", todoIds: todoIds)
        } catch {
            print("Error dragAndDrop: \(error)")
        }
    }
    
    func editToday(todoId: Int, content: String) async {
        do {
            await MainActor.run {
                selectedTodoItem = nil
            }
            try await backlogRepository.editBacklog(todoId: todoId, content: content)
        } catch {
            print("Error edit today: \(error)")
        }
    }
    
    func deleteTodo(todoId: Int) async {
        do {
            await MainActor.run {
                self.todayList.removeAll { $0.todoId == todoId }
                selectedTodoItem = nil
            }
            
            try await backlogRepository.deleteBacklog(todoId: todoId)
        } catch {
            print("Error delete today: \(error)")
        }
    }
    
    func updateBookmark(todoId: Int) async {
        await MainActor.run { selectedTodoItem?.isBookmark.toggle() }
        
        do {
            try await todoRepository.updateBookmark(todoId: todoId)
            
            await MainActor.run {
                if let index = todayList.firstIndex(where: { $0.todoId == todoId }) {
                    todayList[index].isBookmark.toggle()
                }
            }
        } catch {
            print("Error updateBookmark: \(error)")
        }
    }
    
    func updateDeadline(todoId: Int, deadline: String?) async {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        await MainActor.run { selectedTodoItem?.deadline = deadline }
        
        do {
            try await backlogRepository.updateDeadline(todoId: todoId, request: UpdateDeadlineRequest(deadline: deadline))
            await MainActor.run {
                if let index = todayList.firstIndex(where: { $0.todoId == todoId }) {
                    todayList[index].deadline = deadline
                    
                    if let deadline = deadline,
                        let parsedDate = dateFormatter.date(from: deadline) {
                        
                        let deadlineDate = Calendar.current.startOfDay(for: parsedDate)
                        let currentDate = Calendar.current.startOfDay(for: Date())
                        let calendar = Calendar.current

                        let components = calendar.dateComponents([.day], from: currentDate, to: deadlineDate)
                        if let daysDifference = components.day {
                            todayList[index].dDay = daysDifference
                            selectedTodoItem?.dDay = daysDifference
                        }
                    } else {
                        todayList[index].dDay = nil
                        selectedTodoItem?.dDay = nil
                    }
                }
            }
        } catch {
            print("Error updating deadline: \(error)")
        }
    }
    
    func updateTodoRepeat(todoId: Int) async {
        do {
            try await todoRepository.setTodoRepeat(todoId: todoId)
            
            await MainActor.run {
                if let index = todayList.firstIndex(where: { $0.todoId == todoId }) {
                    todayList[index].isRepeat.toggle()
                }
            }
        } catch {
            print("Error updateTodoRepeat: \(error)")
        }
    }
    
    func updateCategory(categoryId: Int?, todoId: Int) async {
        do {
            let resolvedCategory = categoryId.flatMap { id in
                categoryList.first(where: { $0.id == id })
            }

            await MainActor.run {
                selectedTodoItem?.categoryId = resolvedCategory?.id
                selectedTodoItem?.categoryName = resolvedCategory?.name
                selectedTodoItem?.imageUrl = resolvedCategory?.imageUrl
            }
            
            try await todoRepository.updateCategory(todoId: todoId, categoryId: CategoryIdModel(categoryId: categoryId))
            await getTodayList()
        } catch {
            print("Error updateCategory: \(error)")
        }
    }
    
    func getCategoryList(page: Int, size: Int) async {
        do {
            let response = try await categoryRepository.getCategoryList(page: page, size: size, mobileType: "IOS")
            await MainActor.run {
                categoryList = response.categories
            }
        } catch {
            print("Error getCategoryList: \(error)")
        }
    }
    
    func getTodoDetail(item: TodoItemModel) async {
        do {
            AnalyticsManager.shared.logEvent(AnalyticsEvent.today_bottom_sheet)
            let response = try await todoRepository.getTodoDetail(todoId: item.todoId)
            let categoryId = categoryList.first { category in
                category.name == response.categoryName && category.imageUrl == response.emojiImageUrl
            }?.id
            
            await MainActor.run {
                let newItem = TodoItemModel(
                    todoId: item.todoId,
                    content: item.content,
                    isBookmark: item.isBookmark,
                    isRepeat: item.isRepeat,
                    dDay: item.dDay,
                    deadline: item.deadline,
                    categoryId: categoryId,
                    categoryName: response.categoryName,
                    imageUrl: response.emojiImageUrl
                )
                updateSelectedItem(item: newItem)
            }
        } catch {
            print("Error getTodoDetail: \(error)")
        }
    }
    
    func updateSelectedItem(item: TodoItemModel?) {
        selectedTodoItem = item
    }
}
