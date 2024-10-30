//
//  BacklogRepository.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/26/24.
//

protocol BacklogRepository {
    func createBacklog(request: CreateBacklogRequest) async throws -> TodoIdModel
    func getBacklogList(page: Int, size: Int) async throws -> BacklogListResponse
    func deleteBacklog(todoId: Int) async throws -> Void
    func editBacklog(todoId: Int, content: String) async throws -> Void
    func updateDeadline(todoId: Int, request: UpdateDeadlineRequest) async throws -> Void
}
