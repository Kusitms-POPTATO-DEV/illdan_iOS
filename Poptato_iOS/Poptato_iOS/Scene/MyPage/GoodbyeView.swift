//
//  GoodbyeView.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 4/19/25.
//

import SwiftUI

struct GoodbyeView: View {
    let nickname: String
    
    var deleteAccount: () -> Void
    var onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.gray100.ignoresSafeArea()
            
            VStack {
                Image("ic_goodbye")
                
                Spacer().frame(height: 8)
                
                Text("안녕히가세요, \(nickname)님!")
                    .font(PoptatoTypo.xxxLSemiBold)
                    .foregroundStyle(Color.gray00)
                
                Spacer().frame(height: 8)
                
                Text("더 좋은 서비스를 제공할 수 있도록\n노력하겠습니다.")
                    .font(PoptatoTypo.mdMedium)
                    .foregroundStyle(Color.gray40)
                    .multilineTextAlignment(.center)
            }
        }
        .onAppear {
            deleteAccount()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onDismiss()
            }
        }
    }
}
