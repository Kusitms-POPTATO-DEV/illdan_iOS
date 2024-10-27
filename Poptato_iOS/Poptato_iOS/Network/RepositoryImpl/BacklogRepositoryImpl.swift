//
//  BacklogRepositoryImpl.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/26/24.
//

final class BacklogRepositoryImpl: BacklogRepository {
    func createBacklog(request: CreateBacklogRequest) async throws -> TodoIdModel {
        try await NetworkManager.shared.request(type: TodoIdModel.self, api: .createBacklog(createBacklogRequest: request))
    }
    
    func getBacklogList(page: Int, size: Int) async throws -> BacklogListResponse {
        try await NetworkManager.shared.request(type: BacklogListResponse.self, api: .getBacklogList(page: page, size: size))
    }
    
    func deleteBacklog(todoId: Int) async throws {
        try await NetworkManager.shared.request(api: .deleteBacklog(todoId: todoId))
    }
    
    func editBacklog(todoId: Int, content: String) async throws {
        try await NetworkManager.shared.request(api: .editBacklog(todoId: todoId, content: content))
    }
}
