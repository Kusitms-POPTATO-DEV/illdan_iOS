//
//  Poptato_iOSApp.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/21/24.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct Poptato_iOSApp: App {
    init() {
        KakaoSDK.initSDK(appKey: Secrets.kakaoAppKey)
    }
    
    @State private var finishSplash = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if finishSplash {
                    MainView()
                }
                else {
                    SplashView()
                        .onAppear(perform: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                finishSplash = true
                            }
                        })
                }
            }
        }
    }
}
