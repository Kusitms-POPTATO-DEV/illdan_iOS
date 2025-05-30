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
    @Published var isNewUser: Bool = false
    
    init(repository: AuthRepository = AuthRepositoryImpl()) {
        self.repository = repository
    }
    
    func kakaoLogin(token: String) async {
        do {
            guard let fcmToken = try await FCMManager.shared.getFCMToken() else {
                throw NSError(domain: "FCM", code: -1, userInfo: [NSLocalizedDescriptionKey: "FCM 토큰 발급에 실패했습니다."])
            }
            
            let response = try await repository.kakaoLogin(request: LoginRequest(socialType: "KAKAO", accessToken: token, mobileType: "IOS", clientId: fcmToken, name: nil, email: nil))
            
            AnalyticsManager.shared.logEvent(AnalyticsEvent.kakao_login)
            
            await MainActor.run {
                isLoginSuccess = true
                isNewUser = response.isNewUser
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

        guard let fcmToken = try await FCMManager.shared.getFCMToken() else {
            throw NSError(domain: "FCM", code: -1, userInfo: [NSLocalizedDescriptionKey: "FCM 토큰 발급 실패"])
        }

        let response = try await repository.kakaoLogin(
            request: LoginRequest(
                socialType: "APPLE",
                accessToken: token,
                mobileType: "IOS",
                clientId: fcmToken,
                name: appleIDCredential.fullName?.givenName,
                email: appleIDCredential.email
            )
        )
        
        AnalyticsManager.shared.logEvent(AnalyticsEvent.apple_login)

        await MainActor.run {
            isLoginSuccess = true
            isNewUser = response.isNewUser
            print("Apple Login successful: \(response)")

            KeychainManager.shared.saveToken(response.accessToken, for: "accessToken")
            KeychainManager.shared.saveToken(response.refreshToken, for: "refreshToken")
        }
    }
}
