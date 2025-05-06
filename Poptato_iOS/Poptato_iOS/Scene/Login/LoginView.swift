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
                    UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                        if let error = error {
                            print(error)
                        }
                        if let oauthToken = oauthToken{
                            Task {
                                await viewModel.kakaoLogin(token: oauthToken.accessToken)
                                onSuccessLogin(viewModel.isNewUser)
                            }
                        }
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
}
