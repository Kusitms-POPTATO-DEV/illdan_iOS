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
    var onSuccessLogin: () -> Void
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.gray100
                .edgesIgnoringSafeArea(.all)
            Color.splash
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                Image("ic_stairs")
                    .resizable()
                    .ignoresSafeArea()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
            }
            
            Color.kakaoLogin
                .edgesIgnoringSafeArea(.all)
            
            Image("ic_login")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 137)
                .offset(y: 80)
            
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
                                    // 애플 로그인 성공 처리
                                    try await viewModel.handleAppleLogin(result: authResults)
                                    onSuccessLogin()
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
                                await viewModel.login(token: oauthToken.accessToken)
                                onSuccessLogin()
                            }
                            print("kakao success: \(oauthToken)")
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

#Preview {
    LoginView(
        onSuccessLogin: {}
    )
}
