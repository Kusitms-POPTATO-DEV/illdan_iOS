//
//  MyPageView.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/4/24.
//

import SwiftUI

struct MyPageView: View {
    var goToKaKaoLogin: () -> Void
    var goToUserCommentView: () -> Void
    @EnvironmentObject var viewModel: MyPageViewModel
    @Binding var isPolicyViewPresented: Bool
    @State private var isNoticeViewPresented = false
    @State private var isFaqViewPresented = false
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color(.gray100)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 0) {
                    ProfileInfoView(
                        imageUrl: viewModel.imageUrl,
                        nickname: viewModel.nickname,
                        onClickButton: { path.append(NavRoutes.Settings.info) }
                    )
                    
                    Spacer().frame(height: 32)
                    
                    Text("설정")
                        .font(PoptatoTypo.lgSemiBold)
                        .foregroundColor(.gray00)
                    
                    Spacer().frame(height: 24)
                    
                    SettingMenuListView(
                        deadlineDateMode: $viewModel.deadlineDateMode,
                        isPolicyViewPresented: $isPolicyViewPresented,
                        onClickCommentButton: { goToUserCommentView() }
                    )
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                Task {
                    await viewModel.getUserInfo()
                }
            }
            .navigationDestination(for: NavRoutes.Settings.self) { view in
                switch view {
                case .info:
                    AccountInfoView(
                        onClickBtnLogout: {
                          Task {
                              await viewModel.logout()
                              goToKaKaoLogin()
                          }
                        },
                        onClickBtnDeleteAccount: {
                            Task {
                                await viewModel.deleteAccount()
                            }
                        },
                        onClickBtnBack: {
                            path.removeLast()
                        },
                        goToKaKaoLogin: goToKaKaoLogin,
                        nickname: viewModel.nickname,
                        email: viewModel.email,
                        imageUrl: viewModel.imageUrl,
                        selectedReasons: $viewModel.selectedReasons,
                        userInputReason: $viewModel.userInputReason
                    )
                    .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}

struct ProfileInfoView: View {
    let imageUrl: String
    let nickname: String
    
    var onClickButton: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            if imageUrl.isEmpty {
                Image("ic_empty_profile_image")
                    .resizable()
                    .frame(width: 48, height: 48)
            } else {
                AsyncImageView(imageURL: imageUrl, width: 48, height: 48)
            }
            
            Spacer().frame(width: 16)
            
            Text(nickname)
                .font(PoptatoTypo.lgMedium)
                .foregroundColor(.gray00)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
                .truncationMode(.tail)
            
            Spacer().frame(width: 16)
            
            Image("ic_settings")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .onTapGesture {
                        onClickButton()
                    }
        }
        .frame(maxWidth: .infinity)
    }
}

struct SettingMenuListView: View {
    @Binding var deadlineDateMode: Bool
    @Binding var isPolicyViewPresented: Bool
    
    var onClickCommentButton: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            HStack {
                Text("마감기한 날짜로 보기")
                    .font(PoptatoTypo.mdMedium)
                    .foregroundColor(.gray20)
                
                Spacer()
                
                Toggle("", isOn: $deadlineDateMode)
                    .toggleStyle(SmallToggleStyle())
                    .tint(deadlineDateMode ? Color.primary40 : Color.gray80)
                    .onChange(of: deadlineDateMode) { newValue in
                        CommonSettingsManager.shared.toggleDeadlineMode()
                    }
            }
            
            MyPageButton(text: "개발자에게 의견 보내기", onClickBtn: {
                onClickCommentButton()
            })
            
            MyPageButton(text: "개인정보처리 방침", onClickBtn: {
                AnalyticsManager.shared.logEvent(AnalyticsEvent.terms)
                isPolicyViewPresented = true
            })
            
            HStack {
                Text("버전")
                    .font(PoptatoTypo.mdMedium)
                    .foregroundColor(.gray20)
                
                Spacer()
                
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                    .font(PoptatoTypo.mdMedium)
                    .foregroundColor(.primary40)
            }
            
        }
        .padding(.horizontal, 8)
    }
}

struct MyPageButton: View {
    let text: String
    let onClickBtn: () -> Void
    
    var body: some View {
        HStack {
            Text(text)
                .font(PoptatoTypo.mdMedium)
                .foregroundColor(.gray20)
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onClickBtn()
        }
    }
}
