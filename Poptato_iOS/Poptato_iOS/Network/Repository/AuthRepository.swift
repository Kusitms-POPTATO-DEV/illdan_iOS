//
//  AuthRepository.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/26/24.
//

protocol AuthRepository {
    func kakaoLogin(request: KaKaoLoginRequest) async throws -> KaKaoLoginResponse
}
