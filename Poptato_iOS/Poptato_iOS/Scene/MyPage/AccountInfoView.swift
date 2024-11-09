//
//  AccountInfoView.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/9/24.
//

import SwiftUI

struct AccountInfoView: View {
    @Environment(\.presentationMode) var presentationMode
    var nickname: String
    var email: String
    
    var body: some View {
        ZStack {
            Color(.gray100)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    Text("계정 정보")
                        .font(PoptatoTypo.mdSemiBold)
                        .foregroundColor(.gray00)
                    
                    HStack(alignment: .center) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image("ic_arrow_left")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                
                Spacer().frame(height: 16)
                
                HStack {
                    Image("ic_empty_profile_image")
                        .resizable()
                        .frame(width: 62, height: 62)
                    VStack(alignment: .leading) {
                        Text(nickname)
                            .font(PoptatoTypo.lgSemiBold)
                            .foregroundColor(.gray00)
                        
                        Text(email)
                            .font(PoptatoTypo.smRegular)
                            .foregroundColor(.gray40)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                
                Spacer().frame(height: 16)
                
                Button(action: {
                    
                }) {
                    ZStack(alignment: .center) {
                        Color(.danger50).opacity(0.1)
                        Text("로그아웃")
                            .font(PoptatoTypo.smSemiBold)
                            .foregroundColor(.danger40)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .cornerRadius(8)
                
                Spacer().frame(height: 16)
                
                AccountInfoItem(title: "이름", content: nickname)
                
                Spacer().frame(height: 24)
                
                AccountInfoItem(title: "카카오 로그인", content: email)
                
                Spacer().frame(height: 32)
                
                Button(action: {
                    
                }) {
                    Text("서비스 탈퇴하기")
                        .font(PoptatoTypo.mdMedium)
                        .foregroundColor(.gray70)
                }
                .padding(.horizontal, 8)
                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct AccountInfoItem: View {
    var title: String
    var content: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(PoptatoTypo.smMedium)
                .foregroundColor(.gray40)
            Spacer().frame(height: 10)
            Text(content)
                .font(PoptatoTypo.mdMedium)
                .foregroundColor(.gray00)
        }
        .padding(.horizontal, 8)
    }
}

#Preview {
    AccountInfoView(nickname: "손현수", email: "email1234@email.com")
}
