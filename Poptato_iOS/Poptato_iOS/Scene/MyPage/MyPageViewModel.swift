//
//  MyPageViewModel.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/4/24.
//

import SwiftUI

class MyPageViewModel: ObservableObject {
    private var userRepository: UserRepository
    private var authRepository: AuthRepository
    @Published var nickname: String = ""
    @Published var email: String = ""
    @Published var imageUrl: String = ""
    @Published var policyContent: String = ""
    @Published var deadlineDateMode: Bool
    @Published var userInputReason: String = ""
    @Published var selectedReasons: [Bool] = [false, false, false]
    
    private let list = ["NOT_USED_OFTEN", "MISSING_FEATURES", "TOO_COMPLEX"]
    
    init(userRepository: UserRepository = UserRepositoryImpl(), authRepository: AuthRepository = AuthRepositoryImpl()) {
        self.userRepository = userRepository
        self.authRepository = authRepository
        self.deadlineDateMode = AppStorageManager.deadlineDateMode
    }
    
    func getUserInfo() async {
        do {
            let response = try await userRepository.getUserInfo()
            await MainActor.run {
                nickname = response.name
                email = response.email
                imageUrl = response.imageUrl ?? ""
            }
        } catch {
            print("Error getUserInfo: \(error)")
        }
    }
    
    func getPolicy() async {
        do {
            let response = try await userRepository.getPolicy()
            await MainActor.run {
                policyContent = response.content
            }
        } catch {
            print("Error getPolicy: \(error)")
        }
    }
    
    func logout() async {
        do {
            let clientId = try await FCMManager.shared.getFCMToken()
            
            try await authRepository.logout(request: LogoutRequest(clientId: clientId))
            
            await MainActor.run {
                KeychainManager.shared.deleteToken(for: "accessToken")
                KeychainManager.shared.deleteToken(for: "refreshToken")
            }
        } catch {
            print("Error logout: \(error)")
        }
    }
    
    func deleteAccount() async {
        do {
            AnalyticsManager.shared.logEvent(AnalyticsEvent.delete_account)
            
            var reasons: [String] = []
            
            for index in 0..<3 {
                if selectedReasons[index] {
                    reasons.append(list[index])
                }
            }
            
            try await authRepository.deleteAccount(
                request: DeleteAccountRequest(
                    reasons: reasons.isEmpty ? nil : reasons,
                    userInputReason: userInputReason.isEmpty ? nil : userInputReason
                )
            )
            
            await MainActor.run {
                KeychainManager.shared.deleteToken(for: "accessToken")
                KeychainManager.shared.deleteToken(for: "refreshToken")
            }
        } catch {
            print("Error deleteAccount: \(error)")
        }
    }
    
    func updateDealineMode(_ value: Bool) async {
        AppStorageManager.deadlineDateMode = value
    }
}
