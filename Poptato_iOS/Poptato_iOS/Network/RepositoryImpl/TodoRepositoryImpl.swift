//
//  TodoRepositoryImpl.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/28/24.
//

final class TodoRepositoryImpl: TodoRepository {
    func swipeTodo(request: TodoIdModel) async throws {
        try await NetworkManager.shared.request(api: .swipeTodo(swipeRequest: request))
    }
    
    func updateTodoCompletion(todoId: Int) async throws {
        try await NetworkManager.shared.request(api: .updateTodoCompletion(todoId: todoId))
    }
    
    func updateBookmark(todoId: Int) async throws {
        try await NetworkManager.shared.request(api: .updateBookmark(todoId: todoId))
    }
    
    func dragAndDrop(type: String, todoIds: Array<Int>) async throws {
        try await NetworkManager.shared.request(api: .dragAndDrop(type: type, todoIds: todoIds))
    }
    
    func getYesterdayList(page: Int, size: Int) async throws -> YesterdayListResponse {
        try await NetworkManager.shared.request(type: YesterdayListResponse.self, api: .getYesterdayList(page: page, size: size))
    }
    
    func updateTodoRepeat(todoId: Int) async throws {
        try await NetworkManager.shared.request(api: .updateTodoRepeat(todoId: todoId))
    }
    func getTodoDetail(todoId: Int) async throws -> TodoDetailModel {
        try await NetworkManager.shared.request(type: TodoDetailModel.self, api: .getTodoDetail(todoId: todoId))
    }
    func updateCategory(todoId: Int, categoryId: CategoryIdModel) async throws {
        try await NetworkManager.shared.request(api: .updateCategory(todoId: todoId, categoryId: categoryId))
    }
    
    func updateYesterdayCompletion(todoIdsRequest: TodoIdsRequest) async throws {
        try await NetworkManager.shared.request(api: .updateYesterdayCompletion(todoIdsRequest: todoIdsRequest))
    }
    
    func updateTodoTime(todoId: Int, request: TodoTimeRequest) async throws {
        try await NetworkManager.shared.request(api: .updateTodoTime(todoId: todoId, request: request))
    }
    
    func setTodoRoutine(todoId: Int, request: TodoRoutineRequest) async throws {
        try await NetworkManager.shared.request(api: .setTodoRoutine(todoId: todoId, request: request))
    }
    
    func deleteTodoRoutine(todoId: Int) async throws {
        try await NetworkManager.shared.request(api: .deleteTodoRoutine(todoId: todoId))
    }
}
