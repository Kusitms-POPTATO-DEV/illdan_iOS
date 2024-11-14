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
            Image("bg_motivation_view")
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Text("좋아요! 오늘 하루도\n힘차게 시작해볼까요?")
                .multilineTextAlignment(.center)
                .font(PoptatoTypo.xxLMedium)
                .foregroundColor(.gray10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MotivationView()
}
