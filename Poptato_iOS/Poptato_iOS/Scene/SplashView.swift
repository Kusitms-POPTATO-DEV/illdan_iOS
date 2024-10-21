//
//  SplashView.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/21/24.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack{
            Color.gray100
                .edgesIgnoringSafeArea(.all)
            
            Image("ic_splash")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 137)
                .offset(y: -50)
        }
    }
}

#Preview {
    SplashView()
}
