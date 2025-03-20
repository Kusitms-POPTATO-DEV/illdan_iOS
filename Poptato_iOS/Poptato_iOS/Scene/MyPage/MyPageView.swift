//
//  MyPageView.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/4/24.
//

import SwiftUI

struct MyPageView: View {
    var goToKaKaoLogin: () -> Void
    @StateObject private var viewModel = MyPageViewModel()
    @Binding var isPolicyViewPresented: Bool
    @State private var isNoticeViewPresented = false
    @State private var isFaqViewPresented = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.gray100)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        if viewModel.imageUrl.isEmpty {
                            Image("ic_empty_profile_image")
                                .resizable()
                                .frame(width: 62, height: 62)
                        } else {
                            AsyncImageView(imageURL: viewModel.imageUrl, width: 62, height: 62)
                        }
                        VStack(alignment: .leading) {
                            Text(viewModel.nickname)
                                .font(PoptatoTypo.lgSemiBold)
                                .foregroundColor(.gray00)
                            
                            Text(viewModel.email)
                                .font(PoptatoTypo.smRegular)
                                .foregroundColor(.gray40)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    
                    Spacer().frame(height: 16)
                    
                    NavigationLink(
                        destination: AccountInfoView(
                            onClickBtnLogout: {
                                Task {
                                    await viewModel.logout()
                                    goToKaKaoLogin()
                                }
                            },
                            onClickBtnDeleteAccount: {
                                Task {
                                    await viewModel.deleteAccount()
                                    goToKaKaoLogin()
                                }
                            },
                            nickname: viewModel.nickname,
                            email: viewModel.email
                        )) {
                        ZStack(alignment: .center) {
                            Color(.gray95)
                            Text("계정 정보")
                                .font(PoptatoTypo.smSemiBold)
                                .foregroundColor(.gray00)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .cornerRadius(8)
                    }
                    
                    Spacer().frame(height: 40)
                    
                    Text("설정")
                        .font(PoptatoTypo.lgSemiBold)
                        .foregroundColor(.gray00)
                    
                    Spacer().frame(height: 24)
                    
                    VStack(alignment: .leading, spacing: 32) {
                        HStack {
                            Text("마감기한 날짜로 보기")
                                .font(PoptatoTypo.mdMedium)
                                .foregroundColor(.gray20)
                            
                            Spacer()
                            
                            Toggle("", isOn: $viewModel.deadlineDateMode)
                                .tint(viewModel.deadlineDateMode ? Color.primary60 : Color.gray80)
                                .onChange(of: viewModel.deadlineDateMode) { newValue in
                                    CommonSettingsManager.shared.toggleDeadlineMode()
                                }
                        }
                        Text("공지사항")
                            .font(PoptatoTypo.mdMedium)
                            .foregroundColor(.gray20)
                            .onTapGesture {
                                AnalyticsManager.shared.logEvent(AnalyticsEvent.notice)
                                isNoticeViewPresented = true
                            }
                        Text("문의 & FAQ")
                            .font(PoptatoTypo.mdMedium)
                            .foregroundColor(.gray20)
                            .onTapGesture {
                                AnalyticsManager.shared.logEvent(AnalyticsEvent.faq)
                                isFaqViewPresented = true
                            }
                        Text("개인정보처리 방침")
                            .font(PoptatoTypo.mdMedium)
                            .foregroundColor(.gray20)
                            .onTapGesture {
                                AnalyticsManager.shared.logEvent(AnalyticsEvent.terms)
                                isPolicyViewPresented = true
                            }
                        HStack {
                            Text("버전")
                                .font(PoptatoTypo.mdMedium)
                                .foregroundColor(.gray20)
                            
                            Spacer()
                            
                            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                                .font(PoptatoTypo.mdMedium)
                                .foregroundColor(.primary60)
                        }
                        
                    }
                    .padding(.horizontal, 8)
                    
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
            .fullScreenCover(isPresented: $isNoticeViewPresented) {
                WebViewScreen(url: URL(string: "https://www.notion.so/164d60b563cc8091a84cf5fa4b2addad")!)
            }
            .fullScreenCover(isPresented: $isFaqViewPresented) {
                WebViewScreen(url: URL(string: "https://www.notion.so/FAQ-164d60b563cc80beb7e5c388954353b5")!)
            }
        }
        
    }
}
