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
            await MainActor.run {
                KeychainManager.shared.deleteToken(for: "accessToken")
                KeychainManager.shared.deleteToken(for: "refreshToken")
            }
            
            try await authRepository.logout()
        } catch {
            print("Error logout: \(error)")
        }
    }
    
    func deleteAccount() async {
        do {
            await MainActor.run {
                KeychainManager.shared.deleteToken(for: "accessToken")
                KeychainManager.shared.deleteToken(for: "refreshToken")
            }
            
            try await authRepository.deleteAccount()
        } catch {
            print("Error deleteAccount: \(error)")
        }
    }
    
    func updateDealineMode(_ value: Bool) async {
        AppStorageManager.deadlineDateMode = value
    }
}
