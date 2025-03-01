//
//  AuthRepository.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/26/24.
//

protocol AuthRepository {
    func kakaoLogin(request: LoginRequest) async throws -> LoginResponse
    func refreshToken(request: ReissueTokenRequest) async throws -> TokenModel
    func logout() async throws -> Void
    func deleteAccount() async throws -> Void
}
