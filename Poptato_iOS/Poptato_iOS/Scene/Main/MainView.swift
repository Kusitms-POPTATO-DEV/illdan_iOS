//
//  MainView.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/23/24.
//

import SwiftUI

struct MainView: View {
    @State private var isLogined = false
    
    var body: some View {
        if isLogined {
            TabView {
//                HomeView()
//                    .tabItem {
//                        Label("Home", systemImage: "house")
//                    }
//
//                SettingsView()
//                    .tabItem {
//                        Label("Settings", systemImage: "gearshape")
//                    }
//
//                ProfileView()
//                    .tabItem {
//                        Label("Profile", systemImage: "person")
//                    }
            }
        } else {
            KaKaoLoginView(
                onSuccessLogin: { isLogined = true }
            )
        }
    }
}

#Preview {
    MainView()
}
