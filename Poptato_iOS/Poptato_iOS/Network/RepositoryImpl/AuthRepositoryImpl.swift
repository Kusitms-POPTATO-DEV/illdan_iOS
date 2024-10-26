//
//  AuthRepositoryImpl.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/26/24.
//

final class AuthRepositoryImpl: AuthRepository {
    func kakaoLogin(request: KaKaoLoginRequest) async throws -> KaKaoLoginResponse {
        try await NetworkManager.shared.request(type: KaKaoLoginResponse.self, api: .kakaoLogin(loginRequest: request))
    }
    
    func refreshToken(request: TokenModel) async throws -> TokenModel {
        try await NetworkManager.shared.request(type: TokenModel.self, api: .reissueToken(reissueRequest: request))
    }
}
