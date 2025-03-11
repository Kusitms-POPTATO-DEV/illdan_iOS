//
//  AuthRepositoryImpl.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/26/24.
//

final class AuthRepositoryImpl: AuthRepository {
    func kakaoLogin(request: LoginRequest) async throws -> LoginResponse {
        try await NetworkManager.shared.request(type: LoginResponse.self, api: .kakaoLogin(loginRequest: request))
    }
    
    func refreshToken(request: ReissueTokenRequest) async throws -> TokenModel {
        try await NetworkManager.shared.request(type: TokenModel.self, api: .reissueToken(reissueRequest: request))
    }
    
    func logout(request: LogoutRequest) async throws {
        try await NetworkManager.shared.request(api: .logout(logoutRequest: request))
    }
    
    func deleteAccount() async throws {
        try await NetworkManager.shared.request(api: .deleteAccount)
    }
}
