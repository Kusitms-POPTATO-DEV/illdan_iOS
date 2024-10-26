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
}
