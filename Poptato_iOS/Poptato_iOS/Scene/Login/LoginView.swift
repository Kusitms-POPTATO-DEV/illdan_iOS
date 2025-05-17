//
//  KaKaoLoginView.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/23/24.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import AuthenticationServices

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    var onSuccessLogin: (Bool) -> Void
    
    var body: some View {
        ZStack(alignment: .center) {
            Color.gray100
                .edgesIgnoringSafeArea(.all)
            
            Image("ic_login")
            
            VStack(spacing: 0) {
                Spacer()
                
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        switch result {
                        case .success(let authResults):
                            Task {
                                do {
                                    try await viewModel.handleAppleLogin(result: authResults)
                                    onSuccessLogin(viewModel.isNewUser)
                                } catch {
                                    print("Apple Login Error: \(error)")
                                }
                            }
                        case .failure(let error):
                            print("Apple Login Failed: \(error)")
                        }
                    }
                )
                .signInWithAppleButtonStyle(.black)
                .frame(maxWidth: .infinity, maxHeight: 56)
                .cornerRadius(8)
                .padding(.horizontal, 16)
                
                Spacer().frame(height: 12)

                Button(action: {
                    if UserApi.isKakaoTalkLoginAvailable() {
                        loginWithKaKaoApp()
                    } else {
                        // 앱 미설치 시 계정 로그인
                        loginWithKakaoAccount()
                    }
                }) {
                    HStack {
                        Image("ic_kakao")
                        Spacer().frame(width: 8)
                        Text("카카오 로그인")
                            .font(.custom("PoptatoTypo-Medium", size: 16))
                            .foregroundColor(.gray100)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 56)
                    .background(Color.kakaoMain)
                    .cornerRadius(8)
                }
                .padding(.horizontal, 16)

                Spacer().frame(height: 24)
            }
        }
    }
    
    private func loginWithKaKaoApp() {
        UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
            if let error = error {
                print(error)
                loginWithKakaoAccount()
            } else {
                if let token = oauthToken {
                    Task {
                        await viewModel.kakaoLogin(token: token.accessToken)
                        onSuccessLogin(viewModel.isNewUser)
                    }
                }
            }
        }
    }
    
    private func loginWithKakaoAccount() {
        UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
            if let error = error {
                print(error)
            } else {
                print("loginWithKakaoAccount() success")
                if let token = oauthToken {
                    Task {
                        await viewModel.kakaoLogin(token: token.accessToken)
                        onSuccessLogin(viewModel.isNewUser)
                    }
                }
            }
        }
    }
}
