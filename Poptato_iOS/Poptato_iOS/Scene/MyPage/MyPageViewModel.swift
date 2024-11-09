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
    @Published var nickname: String = "손현수"
    @Published var email: String = "email1234@email.com"
    @Published var policyContent: String = ""
    
    init(userRepository: UserRepository = UserRepositoryImpl(), authRepository: AuthRepository = AuthRepositoryImpl()) {
        self.userRepository = userRepository
        self.authRepository = authRepository
    }
    
    func getUserInfo() async {
        do {
            let response = try await userRepository.getUserInfo()
            await MainActor.run {
                nickname = response.name
                email = response.email
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
            try await authRepository.logout()
            KeychainManager.shared.deleteToken(for: "accessToken")
            KeychainManager.shared.deleteToken(for: "refreshToken")
        } catch {
            print("Error logout: \(error)")
        }
    }
}
