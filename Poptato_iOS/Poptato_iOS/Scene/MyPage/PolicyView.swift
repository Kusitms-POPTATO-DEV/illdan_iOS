//
//  PolicyView.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/9/24.
//

import SwiftUI

struct PolicyView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isPolicyViewPresented: Bool
    @ObservedObject private var viewModel = MyPageViewModel()
    
    var body: some View {
        ZStack {
            Color(.gray100)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ZStack {
                    Text("개인정보처리방침")
                        .font(PoptatoTypo.mdSemiBold)
                        .foregroundColor(.gray00)
                    
                    HStack(alignment: .center) {
                        Spacer()
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                            isPolicyViewPresented = false
                        }) {
                            Image("ic_close")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                
                ScrollView {
                    Text(viewModel.policyContent)
                        .font(PoptatoTypo.smMedium)
                        .foregroundColor(.gray40)
                        .padding(.horizontal, 16)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            Task {
                await viewModel.getPolicy()
            }
        }
    }
}
