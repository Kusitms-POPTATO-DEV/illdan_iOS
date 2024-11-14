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
}
