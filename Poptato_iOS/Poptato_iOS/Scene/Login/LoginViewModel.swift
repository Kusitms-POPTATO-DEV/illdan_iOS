//
//  KaKaoLoginViewModel.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/26/24.
//

import Foundation
import SwiftUI

final class LoginViewModel: ObservableObject {
    private let repository: AuthRepository
    @Published var isLoginSuccess: Bool = false
    @Published var loginError: Error?
    
    init(repository: AuthRepository = AuthRepositoryImpl()) {
        self.repository = repository
    }
    
    func kakaoLogin(token: String) async {
        do {
            let response = try await repository.kakaoLogin(request: KaKaoLoginRequest(socialType: "KAKAO", accessToken: token))
            await MainActor.run {
                isLoginSuccess = true
                print("Login successful: \(response)")
                
                KeychainManager.shared.saveToken(response.accessToken, for: "accessToken")
                KeychainManager.shared.saveToken(response.refreshToken, for: "refreshToken")
            }
        } catch {
            await MainActor.run {
                loginError = error
                print("Login error: \(error)")
            }
        }
    }
}
