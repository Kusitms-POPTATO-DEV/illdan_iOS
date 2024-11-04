//
//  SplashViewModel.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/2/24.
//

import SwiftUI

class SplashViewModel: ObservableObject {
    @Published var accessToken: String?
    @Published var refreshToken: String?
    
    init() {
        accessToken = KeychainManager.shared.readToken(for: "accessToken")
        refreshToken = KeychainManager.shared.readToken(for: "refreshToken")
    }
    
    func checkLogin() -> Bool {
        guard accessToken != nil, refreshToken != nil else {
            return false
        }
        return true
    }
}
