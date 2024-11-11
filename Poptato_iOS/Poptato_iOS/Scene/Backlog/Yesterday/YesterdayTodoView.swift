//
//  YesterdayTodoView.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/11/24.
//

import SwiftUI

struct YesterdayTodoView: View {
    @ObservedObject private var viewModel = YesterdayTodoViewModel()
    @Binding var isYesterdayTodoViewPresented: Bool
    
    var body: some View {
        ZStack {
            Color.gray100.ignoresSafeArea()
            
            VStack {
                ZStack(alignment: .center) {
                    Text("어제 한 일을 모두 체크하세요!")
                        .font(PoptatoTypo.mdMedium)
                        .foregroundColor(.gray00)
                    HStack {
                        Spacer()
                        Image("ic_close")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .onTapGesture {
                                isYesterdayTodoViewPresented = false
                            }
                    }
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarBackButtonHidden()
        .onAppear {
            Task {
                await viewModel.getYesterdayList(page: 0, size: 100)
            }
        }
    }
}
