//
//  BacklogRepository.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/26/24.
//

protocol BacklogRepository {
    func createBacklog(request: CreateBacklogRequest) async throws -> TodoIdModel
    func getBacklogList(page: Int, size: Int) async throws -> BacklogListResponse
}
