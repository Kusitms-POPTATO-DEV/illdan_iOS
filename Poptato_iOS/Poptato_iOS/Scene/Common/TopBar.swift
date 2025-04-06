//
//  TopBar.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/23/24.
//

import SwiftUI

struct TopBar: View {
    var titleText: String = "할 일"
    var subText: String = "8"
    
    var body: some View {
        ZStack {
            Color.gray100
                .ignoresSafeArea(.all)
            
            HStack {
                Text(titleText)
                    .font(PoptatoTypo.xxxLSemiBold)
                    .foregroundColor(.gray00)
                
                Spacer().frame(width: 8)
                
                if (!subText.isEmpty) {
                    Text(subText)
                        .font(PoptatoTypo.xLSemiBold)
                        .foregroundColor(.primary60)
                } else {
                    Image("ic_today_msg_bubble")
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
    }
}

struct TodayTopBar: View {
    let todayDate: String
    
    var body: some View {
        ZStack {
            Color.primary40
                .ignoresSafeArea(.all)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(todayDate)
                        .font(PoptatoTypo.xxxLSemiBold)
                        .foregroundColor(.gray100)
                    
                    Text("오늘도 일단 해보는 거야!")
                        .font(PoptatoTypo.mdMedium)
                        .foregroundColor(.gray100)
                }
                
                Spacer()
                
                VStack {
                    Spacer()
                    Image("ic_today_top_bar")
                }
            }
            .padding(.leading, 20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 76)
    }
}

#Preview {
    TopBar()
}
