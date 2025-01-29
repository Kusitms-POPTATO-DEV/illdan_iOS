//
//  KaKaoLoginViewModel.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/26/24.
//

import Foundation
import SwiftUI
import Firebase
import AuthenticationServices

final class LoginViewModel: ObservableObject {
    private let repository: AuthRepository
    @Published var isLoginSuccess: Bool = false
    @Published var loginError: Error?
    
    init(repository: AuthRepository = AuthRepositoryImpl()) {
        self.repository = repository
    }
    
    func login(token: String) async {
        do {
            guard let fcmToken = try await getFCMToken() else {
                throw NSError(domain: "FCM", code: -1, userInfo: [NSLocalizedDescriptionKey: "FCM 토큰 발급에 실패했습니다."])
            }
            
            let response = try await repository.kakaoLogin(request: LoginRequest(socialType: "KAKAO", accessToken: token, mobileType: "IOS", clientId: fcmToken))
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
    
    func handleAppleLogin(result: ASAuthorization) async throws {
        guard let appleIDCredential = result.credential as? ASAuthorizationAppleIDCredential else {
            throw NSError(domain: "AppleLogin", code: -1, userInfo: [NSLocalizedDescriptionKey: "애플 로그인 인증 실패"])
        }

        let identityToken = appleIDCredential.identityToken
        guard let token = identityToken.flatMap({ String(data: $0, encoding: .utf8) }) else {
            throw NSError(domain: "AppleLogin", code: -2, userInfo: [NSLocalizedDescriptionKey: "애플 토큰 발급 실패"])
        }

        guard let fcmToken = try await getFCMToken() else {
            throw NSError(domain: "FCM", code: -1, userInfo: [NSLocalizedDescriptionKey: "FCM 토큰 발급 실패"])
        }

        let response = try await repository.kakaoLogin(
            request: LoginRequest(
                socialType: "APPLE",
                accessToken: token,
                mobileType: "IOS",
                clientId: fcmToken
            )
        )

        await MainActor.run {
            isLoginSuccess = true
            print("Apple Login successful: \(response)")

            KeychainManager.shared.saveToken(response.accessToken, for: "accessToken")
            KeychainManager.shared.saveToken(response.refreshToken, for: "refreshToken")
        }
    }
    
    private func getFCMToken() async throws -> String? {
        try await withCheckedThrowingContinuation { continuation in
            Messaging.messaging().token { token, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: token)
                }
            }
        }
    }
}
