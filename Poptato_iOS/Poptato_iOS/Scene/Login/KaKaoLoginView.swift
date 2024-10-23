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
    var onSuccessLogin: () -> Void
    
    var body: some View {
        ZStack {
            Color.gray100
                .edgesIgnoringSafeArea(.all)
            
            Image("ic_splash")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 137)
                .offset(y: -50)
            
            VStack {
                Spacer()

                Button(action: {
                    if (UserApi.isKakaoTalkLoginAvailable()) {
                        UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                            if let error = error {
                                print(error)
                            }
                            if let oauthToken = oauthToken{
                                onSuccessLogin()
                                print("kakao success: \(oauthToken)")
                            }
                        }
                    } else {
                        UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                            if let error = error {
                                print(error)
                            }
                            if let oauthToken = oauthToken{
                                onSuccessLogin()
                                print("kakao success: \(oauthToken)")
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

#Preview {
    KaKaoLoginView(
        onSuccessLogin: {}
    )
}
