//
//  KaKaoLoginViewModel.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/26/24.
//

import Foundation
import SwiftUI

final class KaKaoLoginViewModel: ObservableObject {
    private let repository: AuthRepository
    @Published var isLoginSuccess: Bool = false
    @Published var loginError: Error?
    
    init(repository: AuthRepository = AuthRepositoryImpl()) {
        self.repository = repository
    }
    
    func kakaoLogin(token: String) async {
        do {
            let response = try await repository.kakaoLogin(request: KaKaoLoginRequest(kakaoCode: token))
            DispatchQueue.main.async {
                self.isLoginSuccess = true
                print("Login successful: \(response)")
            }
        } catch {
            DispatchQueue.main.async {
                self.loginError = error
                print("Login error: \(error)")
            }
        }
    }
}
