//
//  MyPageViewModel.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/4/24.
//

import SwiftUI

class MyPageViewModel: ObservableObject {
    private var userRepository: UserRepository
    @Published var nickname: String = "손현수"
    @Published var email: String = "email1234@email.com"
    
    init(userRepository: UserRepository = UserRepositoryImpl()) {
        self.userRepository = userRepository
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
}
