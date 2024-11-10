//
//  TodoRepository.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/28/24.
//

protocol TodoRepository {
    func swipeTodo(request: TodoIdModel) async throws -> Void
    func updateTodoCompletion(todoId: Int) async throws -> Void
    func updateBookmark(todoId: Int) async throws -> Void
    func dragAndDrop(type: String, todoIds: Array<Int>) async throws -> Void
}
