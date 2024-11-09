//
//  MyPageView.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/4/24.
//

import SwiftUI

struct MyPageView: View {
    @ObservedObject private var viewModel = MyPageViewModel()
    @Binding var isPolicyViewPresented: Bool
    
    var body: some View {
        ZStack {
            Color(.gray100)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Image("ic_empty_profile_image")
                        .resizable()
                        .frame(width: 62, height: 62)
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
                
                ZStack(alignment: .center) {
                    Color(.gray95)
                    Text("계정 정보")
                        .font(PoptatoTypo.smSemiBold)
                        .foregroundColor(.gray00)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .cornerRadius(8)
                
                Spacer().frame(height: 40)
                
                Text("설정")
                    .font(PoptatoTypo.lgSemiBold)
                    .foregroundColor(.gray00)
                
                Spacer().frame(height: 24)
                
                VStack(alignment: .leading, spacing: 32) {
                    Text("공지사항")
                        .font(PoptatoTypo.mdMedium)
                        .foregroundColor(.gray20)
                    Text("문의 & FAQ")
                        .font(PoptatoTypo.mdMedium)
                        .foregroundColor(.gray20)
                    Text("개인정보처리 방침")
                        .font(PoptatoTypo.mdMedium)
                        .foregroundColor(.gray20)
                        .onTapGesture {
                            isPolicyViewPresented = true
                        }
                    Text("버전")
                        .font(PoptatoTypo.mdMedium)
                        .foregroundColor(.gray20)
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
    }
}
