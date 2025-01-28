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

struct KaKaoLoginView: View {
    @StateObject private var viewModel = KaKaoLoginViewModel()
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
            
            VStack {
                Spacer()

                Button(action: {
                    UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                        if let error = error {
                            print(error)
                        }
                        if let oauthToken = oauthToken{
                            Task {
                                await viewModel.kakaoLogin(token: oauthToken.accessToken)
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
    KaKaoLoginView(
        onSuccessLogin: {}
    )
}
