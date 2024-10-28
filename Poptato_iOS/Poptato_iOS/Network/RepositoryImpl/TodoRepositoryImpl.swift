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
}
