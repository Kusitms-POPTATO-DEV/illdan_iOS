//
//  MainViewModel.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 5/24/25.
//

import SwiftUI
import Combine

final class TodoViewModel: ObservableObject {
    private let todoRepository: TodoRepository
    private let categoryRepository: CategoryRepository
    private let todayRepository: TodayRepository
    private let backlogRepository: BacklogRepository
    private var cancellables = Set<AnyCancellable>()
    
    /// 인앱 리뷰 요청 시점을 알리는 퍼블리셔
    let reviewRequest = PassthroughSubject<Void, Never>()
    
    @Published var selectedTodoItem: TodoItemModel? = .placeholder
    
    /// 오늘 페이지 상태 변수
    @Published var todayList: Array<TodayItemModel> = []
    @Published var currentDate: String = ""
    
    /// 할 일 페이지 상태 변수
    @Published var backlogList: Array<TodoItemModel> = []
    
    /// 어제 한 일 페이지 플래그 변수
    @Published var isExistYesterdayTodo: Bool = false
    
    /// 할 일 수정 상태 변수
    @Published var activeItemId: Int? = nil
    @Published var editingContent: String = ""
    
    /// 가이드 말풍선 상태 변수
    @Published var showFirstGuideBubble: Bool = false
    @Published var showSecondGuideBubble: Bool = false
    @Published var showThirdGuideBubble: Bool = false
    
    /// 카테고리 관련 상태 변수
    @Published var isCategoryEditMode: Bool = false
    @Published var isCategoryCreated: Bool = false
    @Published var isCategoryEdited: Bool = false
    @Published var selectedCategoryIndex: Int = 0
    @Published var categoryList: Array<CategoryModel> = []
    @Published var showCategorySettingMenu: Bool = false
    @Published var showDeleteCategoryDialog: Bool = false
    @Published var scrollToLast: Bool = false
    
    /// 신규 유저 플래그 변수
    @Published var isNewUser: Bool = false
    
    /// 마감기한 날짜 모드 플래그 변수
    @Published var deadlineDateMode: Bool
    
    /// 바텀시트가 할 일 페이지, 오늘 페이지 중 어떤 곳에서 렌더링되었는지 나타내는 플래그 변수
    @Published var isToday: Bool = false
    
    // MARK: - 생성자
    
    init(
        todoRepository: TodoRepository = TodoRepositoryImpl(),
        categoryRepository: CategoryRepository = CategoryRepositoryImpl(),
        todayRepository: TodayRepository = TodayRepositoryImpl(),
        backlogRepository: BacklogRepository = BacklogRepositoryImpl()
    ) {
        self.todoRepository = todoRepository
        self.categoryRepository = categoryRepository
        self.todayRepository = todayRepository
        self.backlogRepository = backlogRepository
        self.deadlineDateMode = AppStorageManager.deadlineDateMode
        
        Task {
            await getCategoryList(page: 0, size: 100)
            await getTodayList()
            await getBacklogList()
        }
        
        CommonSettingsManager.shared.$deadlineDateMode
                    .sink { [weak self] newValue in
                        self?.deadlineDateMode = newValue
                    }
                    .store(in: &cancellables)
    }
    
    // MARK: - 바텀시트 관련 메서드
    
    /// 역할: 특정 할 일의 상세 조회를 실행
    /// 상황: 오늘, 할 일 페이지에서 점 세개를 클릭하는 경우 호출
    func getTodoDetail(item: TodoItemModel, isToday: Bool) async {
        await MainActor.run { self.isToday = isToday }
        
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
                    imageUrl: response.emojiImageUrl,
                    time: response.time,
                    isRoutine: response.isRoutine,
                    routineDays: response.routineDays
                )
                updateSelectedTodo(item: newItem)
            }
        } catch {
            print("Error getTodoDetail: \(error)")
        }
    }
    
    /// 역할: 바텀시트에서 조작될 할 일 상태 변수를 업데이트
    /// 상황: getTodoDetail 메서드에서 함께 실행
    func updateSelectedTodo(item: TodoItemModel?) {
        selectedTodoItem = item
    }
    
    // MARK: - 오늘, 할 일 페이지 공통 메서드
    
    func updateBookmark(todoId: Int) async {
        await MainActor.run { selectedTodoItem?.isBookmark.toggle() }
        
        do {
            try await todoRepository.updateBookmark(todoId: todoId)
            
            await MainActor.run {
                if isToday {
                    if let index = todayList.firstIndex(where: { $0.todoId == todoId }) {
                        todayList[index].isBookmark.toggle()
                    }
                } else {
                    if let index = backlogList.firstIndex(where: { $0.todoId == todoId }) {
                        backlogList[index].isBookmark.toggle()
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                print("Error updateBookmark: \(error)")
            }
        }
    }
    
    func updateDeadline(todoId: Int, deadline: String?) async {
        await MainActor.run { selectedTodoItem?.deadline = deadline }
        
        do {
            try await backlogRepository.updateDeadline(todoId: todoId, request: UpdateDeadlineRequest(deadline: deadline))
            
            await MainActor.run {
                updateDeadlineInUI(todoId: todoId, deadline: deadline)
            }
        } catch {
            print("Error updating deadline: \(error)")
        }
    }
    
    private func updateDeadlineInUI(todoId: Int, deadline: String?) {
        if isToday {
            if let index = todayList.firstIndex(where: { $0.todoId == todoId }) {
                todayList[index].deadline = deadline
                
                if let deadline = deadline,
                   let parsedDate = TimeFormatter.formatDate(date: deadline) {
                    
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
        } else {
            if let index = backlogList.firstIndex(where: { $0.todoId == todoId }) {
                backlogList[index].deadline = deadline
                
                if let deadline = deadline,
                   let parsedDate = TimeFormatter.formatDate(date: deadline) {
                    
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
    }
    
    func setTodoRepeat(todoId: Int) async {
        do {
            try await todoRepository.setTodoRepeat(todoId: todoId)
            
            await MainActor.run {
                if isToday {
                    if let index = todayList.firstIndex(where: { $0.todoId == todoId }) {
                        todayList[index].isRepeat = true
                        todayList[index].routineDays = []
                    }
                } else {
                    if let index = backlogList.firstIndex(where: { $0.todoId == todoId }) {
                        backlogList[index].isRepeat = true
                        backlogList[index].routineDays = []
                    }
                }
                selectedTodoItem?.isRepeat = true
                selectedTodoItem?.routineDays = []
            }
        } catch {
            print("Error setTodoRepeat: \(error)")
        }
    }
    
    func deleteTodoRepeat(todoId: Int) async {
        do {
            try await todoRepository.deleteTodoRepeat(todoId: todoId)
            
            await MainActor.run {
                if isToday {
                    if let index = todayList.firstIndex(where: { $0.todoId == todoId }) {
                        todayList[index].isRepeat = false
                    }
                } else {
                    if let index = backlogList.firstIndex(where: { $0.todoId == todoId }) {
                        backlogList[index].isRepeat = false
                    }
                }
                selectedTodoItem?.isRepeat = false
            }
        } catch {
            print("Error deleteTodoRepeat: \(error)")
        }
    }
    
    func setTodoRoutine(todoId: Int, days: Set<Int>) async {
        do {
            try await todoRepository.setTodoRoutine(todoId: todoId, request: TodoRoutineRequest(routineDays: days.toWeekdays))
            
            await MainActor.run {
                if isToday {
                    if let index = todayList.firstIndex(where: { $0.todoId == todoId }) {
                        todayList[index].routineDays = days.toWeekdays
                        todayList[index].isRoutine = true
                        todayList[index].isRepeat = false
                    }
                } else {
                    if let index = backlogList.firstIndex(where: { $0.todoId == todoId }) {
                        backlogList[index].routineDays = days.toWeekdays
                        backlogList[index].isRoutine = true
                        backlogList[index].isRepeat = false
                    }
                }
                selectedTodoItem?.routineDays = days.toWeekdays
                selectedTodoItem?.isRoutine = true
                selectedTodoItem?.isRepeat = false
            }
        } catch {
            print("Error setTodoRoutine: \(error)")
        }
    }
    
    func deleteTodoRoutine(todoId: Int) async {
        do {
            try await todoRepository.deleteTodoRoutine(todoId: todoId)
            
            await MainActor.run {
                if isToday {
                    if let index = todayList.firstIndex(where: { $0.todoId == todoId }) {
                        todayList[index].routineDays = []
                        todayList[index].isRoutine = false
                    }
                } else {
                    if let index = backlogList.firstIndex(where: { $0.todoId == todoId }) {
                        backlogList[index].routineDays = []
                        backlogList[index].isRoutine = false
                    }
                }
                selectedTodoItem?.routineDays = []
                selectedTodoItem?.isRoutine = false
            }
        } catch {
            print("Error setTodoRoutine: \(error)")
        }
    }
    
    /// 역할: 특정 할 일의 카테고리를 변경
    /// 상황: 1. 바텀시트에서 할 일의 카테고리를 변경하는 경우
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
            if isToday { await getTodayList() } else { await getBacklogList() }
        } catch {
            print("Error updateCategory: \(error)")
        }
    }
    
    /// 역할: 특정 할 일의 시간 정보를 변경
    /// 상황: 시간 바텀시트에서 확인, 삭제를 클릭했을 때 실행
    func updateTodoTime(timeInfo: TimeInfo?) async {
        guard let id = selectedTodoItem?.todoId else { return }
        
        do {
            if let info = timeInfo {
                let time = TimeFormatter.convertTimeInfoToString(info: info)
                try await todoRepository.updateTodoTime(todoId: id, request: TodoTimeRequest(todoTime: time))
                
                AnalyticsManager.shared.logEvent(AnalyticsEvent.set_time)
                
                await MainActor.run {
                    selectedTodoItem?.time = time
                    updateTodoTimeInUI(time: time, id: id)
                }
            } else {
                try await todoRepository.updateTodoTime(todoId: id, request: TodoTimeRequest(todoTime: nil))
                
                await MainActor.run {
                    selectedTodoItem?.time = nil
                    updateTodoTimeInUI(time: nil, id: id)
                }
            }
        } catch {
            print("할 일 시간 정보 업데이트 실패: \(error)")
        }
    }
    
    private func updateTodoTimeInUI(time: String?, id: Int) {
        if isToday {
            if let index = todayList.firstIndex(where: { $0.todoId == id }) {
                todayList[index].time = time
            }
        } else {
            if let index = backlogList.firstIndex(where: { $0.todoId == id }) {
                backlogList[index].time = time
            }
        }
    }
    
    func deleteTodo(todoId: Int) async {
        do {
            if isToday {
                await MainActor.run {
                    self.todayList.removeAll { $0.todoId == todoId }
                }
            } else {
                await MainActor.run {
                    self.backlogList.removeAll { $0.todoId == todoId }
                }
            }
            await MainActor.run { selectedTodoItem = nil }
            
            try await backlogRepository.deleteBacklog(todoId: todoId)
        } catch {
            print("Error delete backlog: \(error)")
        }
    }
    
    // MARK: - 오늘 페이지 관련 메서드
    
    /// 역할: 오늘 할 일 리스트를 조회
    /// 상황: 1. 오늘 할 일의 생성, 수정, 삭제, 순서 변경 이벤트가 발생하는 경우
    func getTodayList() async {
        do {
            let response = try await todayRepository.getTodayList(page: 0, size: 100)
            
            await MainActor.run {
                todayList = response.todays
            }
        } catch {
            print("Error getTodayList \(error)")
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
            
            AppStorageManager.incrementTodoCompletionCount()
            
            let count = AppStorageManager.todoCompletionCount
            print("count: \(count)")
            if count == 10 || count == 40 || count == 80 {
                await MainActor.run {
                    reviewRequest.send(())
                }
            }
            
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
    
    func todayDragAndDrop() async {
        do {
            AnalyticsManager.shared.logEvent(AnalyticsEvent.drag_today)
            let todoIds = todayList.map{ $0.todoId }
            try await todoRepository.dragAndDrop(type: "TODAY", todoIds: todoIds)
        } catch {
            print("Error dragAndDrop: \(error)")
        }
    }
    
    // MARK: - 할 일 페이지 관련 메서드
    
    func createBacklog(_ item: String) async {
        do {
            let response = try await backlogRepository.createBacklog(request: CreateBacklogRequest(categoryId: categoryList[selectedCategoryIndex].id, content: item))
            await getBacklogList()
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
    
    func getBacklogList() async {
        if categoryList.isEmpty { return }
        
        do {
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
    
    func dragAndDrop() async {
        do {
            AnalyticsManager.shared.logEvent(AnalyticsEvent.drag_tasks)
            let todoIds = backlogList.map { $0.todoId }
            try await todoRepository.dragAndDrop(type: "BACKLOG", todoIds: todoIds)
        } catch {
            print("Error dragAndDrop: \(error)")
        }
    }
    
    // MARK: - 카테고리 관련 메서드
    
    /// 역할: 카테고리 리스트를 조회
    /// 상황: 1. TodoViewModel이 생성되는 경우, 2. 카테고리의 생성, 삭제, 수정, 순서 변경 이벤트가 발생한 경우
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
            await getBacklogList()
        } catch {
            print("Error deleteCategory: \(error)")
        }
    }
    
    // MARK: - 어제 한 일 페이지 메서드
    
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
}

extension Set<Int> {
    var toWeekdays: [String] {
        let indexToDayMap = [
            0: "월",
            1: "화",
            2: "수",
            3: "목",
            4: "금",
            5: "토",
            6: "일"
        ]
        return self.sorted().compactMap { indexToDayMap[$0] }
    }
}
