//
//  AccountInfoView.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/9/24.
//

import SwiftUI

struct AccountInfoView: View {
    var onClickBtnLogout: () -> Void
    var onClickBtnDeleteAccount: () -> Void
    var onClickBtnBack: () -> Void
    var goToKaKaoLogin: () -> Void
    
    let nickname: String
    let email: String
    let imageUrl: String
    @State private var isLogoutDialogPresented = false
    @State private var showAccountWithdrawalReasonView = false
    @State private var showGoodbyeView = false
    @Binding var selectedReasons: [Bool]
    @Binding var userInputReason: String
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Color(.gray100)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    Text("계정 정보")
                        .font(PoptatoTypo.mdSemiBold)
                        .foregroundColor(.gray00)
                    
                    HStack(alignment: .center) {
                        Button(action: {
                            onClickBtnBack()
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
                    if imageUrl.isEmpty {
                        Image("ic_empty_profile_image")
                            .resizable()
                            .frame(width: 48, height: 48)
                    } else {
                        AsyncImageView(imageURL: imageUrl, width: 48, height: 48)
                    }
                    
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
                    isLogoutDialogPresented = true
                }) {
                    ZStack(alignment: .center) {
                        Color(.gray95)
                        Text("로그아웃")
                            .font(PoptatoTypo.smSemiBold)
                            .foregroundColor(.gray40)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .cornerRadius(8)
                
                Spacer().frame(height: 16)
                
                AccountInfoItem(title: "이름", content: nickname)
                
                Spacer().frame(height: 24)
                
                AccountInfoItem(title: "로그인 정보", content: email)
                
                Spacer().frame(height: 32)
                
                Button(action: {
                    showAccountWithdrawalReasonView = true
                }) {
                    Text("서비스 탈퇴하기")
                        .font(PoptatoTypo.mdMedium)
                        .foregroundColor(.gray70)
                }
                .padding(.horizontal, 8)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            
            if isLogoutDialogPresented {
                Color.gray100.opacity(0.7)
                    .ignoresSafeArea()
                
                CommonDialog(
                    content: "로그아웃 하시겠어요?",
                    positiveButtonText: "로그아웃",
                    negativeButtonText: "돌아가기",
                    onClickBtnPositive: {
                        onClickBtnLogout()
                        isLogoutDialogPresented = false
                    },
                    onClickBtnNegative: { isLogoutDialogPresented = false },
                    onDismissRequest: { isLogoutDialogPresented = false }
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $showAccountWithdrawalReasonView) {
            AccountWithdrawalReasonView(
                selectedReasons: $selectedReasons,
                userInputReason: $userInputReason,
                onClickBtnClose: { showAccountWithdrawalReasonView = false },
                showGoodbyeView: { showGoodbyeView = true }
            )
        }
        .fullScreenCover(isPresented: $showGoodbyeView) {
            GoodbyeView(
                nickname: nickname,
                deleteAccount: onClickBtnDeleteAccount,
                onDismiss: goToKaKaoLogin
            )
        }
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
