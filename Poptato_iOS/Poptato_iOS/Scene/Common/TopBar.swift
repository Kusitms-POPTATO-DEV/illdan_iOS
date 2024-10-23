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
                
                Text(subText)
                    .font(PoptatoTypo.xLSemiBold)
                    .foregroundColor(.primary60)
                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .frame(width: .infinity, height: 56)
    }
}

#Preview {
    TopBar()
}
