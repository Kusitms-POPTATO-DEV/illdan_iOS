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
        }
    }
}

#Preview {
    SplashView()
}
