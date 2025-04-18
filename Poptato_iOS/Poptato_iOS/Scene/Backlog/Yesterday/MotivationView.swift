//
//  MotivationView.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/12/24.
//

import SwiftUI

struct MotivationView: View {
    var body: some View {
        ZStack(alignment: .center) {
            Color.gray100.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("좋아요! 오늘 하루도\n힘차게 시작해볼까요?")
                    .multilineTextAlignment(.center)
                    .font(PoptatoTypo.xLSemiBold)
                    .foregroundColor(.gray00)
                
                Image("ic_motivation_fire")
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MotivationView()
}
