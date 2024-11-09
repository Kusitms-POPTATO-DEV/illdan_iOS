//
//  UserRepositoryImpl.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/6/24.
//

class UserRepositoryImpl: UserRepository {
    func getUserInfo() async throws -> UserInfoResponse {
        try await NetworkManager.shared.request(type: UserInfoResponse.self, api: .getUserInfo)
    }
    
    func getPolicy() async throws -> PolicyResponse {
        try await NetworkManager.shared.request(type: PolicyResponse.self, api: .getPolicy)
    }
}
