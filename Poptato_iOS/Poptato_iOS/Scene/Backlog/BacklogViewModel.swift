//
//  BacklogViewModel.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/23/24.
//

import SwiftUI
import Combine

final class BacklogViewModel: ObservableObject {
    private var tempIdCounter = -1
    private let backlogRepository: BacklogRepository
    private let todoRepository: TodoRepository
    private let categoryRepository: CategoryRepository
    private var cancellables = Set<AnyCancellable>()
    @Published var isExistYesterdayTodo: Bool = false
    @Published var backlogList: Array<TodoItemModel> = []
    @Published var activeItemId: Int? = nil
    @Published var editingContent: String = ""
    @Published var selectedTodoItem: TodoItemModel? = nil
    @Published var categoryList: Array<CategoryModel> = []
    @Published var selectedCategoryIndex: Int = 0
    @Published var showCategorySettingMenu: Bool = false
    @Published var showDeleteCategoryDialog: Bool = false
    @Published var isCategoryEditMode: Bool = false
    @Published var deadlineDateMode: Bool
    @Published var isNewUser: Bool = false
    @Published var showFirstGuideBubble: Bool = false
    @Published var showSecondGuideBubble: Bool = false
    
    init(
        backlogRepository: BacklogRepository = BacklogRepositoryImpl(),
        todoRepository: TodoRepository = TodoRepositoryImpl(),
        categoryRepository: CategoryRepository = CategoryRepositoryImpl()
    ) {
        self.backlogRepository = backlogRepository
        self.todoRepository = todoRepository
        self.categoryRepository = categoryRepository
        self.deadlineDateMode = AppStorageManager.deadlineDateMode
        Task {
            await getYesterdayList(page: 0, size: 1)
            await getCategoryList(page: 0, size: 100)
        }
        
        CommonSettingsManager.shared.$deadlineDateMode
                    .sink { [weak self] newValue in
                        self?.deadlineDateMode = newValue
                    }
                    .store(in: &cancellables)
    }
    
    func createBacklog(_ item: String) async {
        do {
            let response = try await backlogRepository.createBacklog(request: CreateBacklogRequest(categoryId: categoryList[selectedCategoryIndex].id, content: item))
            await fetchBacklogList()
            await MainActor.run {
                if isNewUser { showFirstGuideBubble = true }
            }
            AnalyticsManager.shared.logEvent(
                AnalyticsEvent.make_task,
                parameters: [
                    "add_date" : TimeFormatter.currentDateString(),
                    "task_ID" : response.todoId,
                    "category_name" : categoryList[selectedCategoryIndex].name
                ]
            )
        } catch {
            print("Login error: \(error)")
        }
    }
    
    func fetchBacklogList() async {
        do {
            AnalyticsManager.shared.logEvent(AnalyticsEvent.get_backlog_list)
            AnalyticsManager.shared.logEvent(
                AnalyticsEvent.view_category,
                parameters: [
                    "category_name" : categoryList[selectedCategoryIndex].name
                ]
            )
            let response = try await backlogRepository.getBacklogList(page: 0, size: 100, categoryId: categoryList[selectedCategoryIndex].id)
            await MainActor.run {
                backlogList = response.backlogs
            }
        } catch {
            DispatchQueue.main.async {
                print("Error fetching backlog list: \(error)")
            }
        }
    }
    
    func deleteBacklog(todoId: Int) async {
        do {
            await MainActor.run {
                self.backlogList.removeAll { $0.todoId == todoId }
                selectedTodoItem = nil
            }
            
            try await backlogRepository.deleteBacklog(todoId: todoId)
        } catch {
            DispatchQueue.main.async {
                print("Error delete backlog: \(error)")
            }
        }
    }
    
    func editBacklog(todoId: Int, content: String) async {
        guard let index = backlogList.firstIndex(where: { $0.todoId == todoId }) else { return }
        let originalData = backlogList[index]
        
        do {
            await MainActor.run {
                backlogList[index].content = content
                selectedTodoItem = nil
            }
            
            try await backlogRepository.editBacklog(todoId: todoId, content: content)
        } catch {
            await MainActor.run {
                backlogList[index] = originalData
            }
            
            print("Error edit backlog: \(error)")
        }
    }
    
    func swipeBacklog(todoId: Int) async {
        do {
            try await todoRepository.swipeTodo(request: TodoIdModel(todoId: todoId))
            
            if isNewUser {
                await MainActor.run {
                    isNewUser = false
                    showFirstGuideBubble = false
                    showSecondGuideBubble = true
                }
            }
            
            AnalyticsManager.shared.logEvent(
                AnalyticsEvent.add_today,
                parameters: [
                    "add_date" : TimeFormatter.currentDateString(),
                    "task_ID" : todoId
                ]
            )
        } catch {
            DispatchQueue.main.async {
                print("Error swipe backlog: \(error)")
            }
        }
    }
    
    func updateBookmark(todoId: Int) async {
        await MainActor.run { selectedTodoItem?.isBookmark.toggle() }
        
        do {
            try await todoRepository.updateBookmark(todoId: todoId)
            
            await MainActor.run {
                if let index = backlogList.firstIndex(where: { $0.todoId == todoId }) {
                    backlogList[index].isBookmark.toggle()
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
                            backlogList[index].dDay = daysDifference
                            selectedTodoItem?.dDay = daysDifference
                        }
                    } else {
                        backlogList[index].dDay = nil
                        selectedTodoItem?.dDay = nil
                    }
                }
            }
        } catch {
            print("Error updating deadline: \(error)")
        }
    }
    
    func getTodoDetail(item: TodoItemModel) async {
        do {
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
    
    func dragAndDrop() async {
        do {
            AnalyticsManager.shared.logEvent(AnalyticsEvent.drag_tasks)
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
                else {
                    isExistYesterdayTodo = false
                }
            }
        } catch {
            print("Error getYesterdayList: \(error)")
        }
    }
    
    // Category
    
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
    
    func categoryDragAndDrop() async {
        do {
            let categoryIds = categoryList.dropFirst(2).map { $0.id }
            try await categoryRepository.categoryDragAndDrop(categoryIds: categoryIds)
        } catch {
            print("Error categoryDragAndDrop: \(error)")
        }
    }

    func updateTodoRepeat(todoId: Int) async {
        do {
            try await todoRepository.updateTodoRepeat(todoId: todoId)
            
            await MainActor.run {
                if let index = backlogList.firstIndex(where: { $0.todoId == todoId }) {
                    backlogList[index].isRepeat.toggle()
                }
            }
        } catch {
            print("Error updateTodoRepeat: \(error)")
        }
    }
    
    func deleteCategory() async {
        do {
            AnalyticsManager.shared.logEvent(
                AnalyticsEvent.delete_category,
                parameters: ["category_name" : categoryList[selectedCategoryIndex].name]
            )
            let categoryId = categoryList[selectedCategoryIndex].id
            
            await MainActor.run {
                self.selectedCategoryIndex = 0
                self.showCategorySettingMenu = false
                self.showDeleteCategoryDialog = false
            }
            
            await MainActor.run {
                self.categoryList.removeAll { $0.id ==  categoryId }
            }
            
            try await categoryRepository.deleteCategory(categoryId: categoryId)
            await fetchBacklogList()
        } catch {
            print("Error deleteCategory: \(error)")
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
            await fetchBacklogList()
        } catch {
            print("Error updateCategory: \(error)")
        }
    }
}
