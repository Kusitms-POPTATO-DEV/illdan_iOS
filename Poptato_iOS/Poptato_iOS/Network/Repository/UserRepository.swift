//
//  UserRepository.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/6/24.
//

protocol UserRepository {
    func getUserInfo() async throws -> UserInfoResponse
}
