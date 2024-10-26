//
//  MainView.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/23/24.
//

import SwiftUI

struct MainView: View {
    @State private var isLogined = false
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.gray100)
    
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.gray90)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Color.gray80)]
        
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.primary60)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color.primary60)]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        ZStack {
            if isLogined {
                TabView {
                    BacklogView()
                        .tabItem {
                            Label("할 일", image: "ic_backlog_selected")
                                .font(PoptatoTypo.xsMedium)
                        }
                }
            } else {
                KaKaoLoginView(
                    onSuccessLogin: { isLogined = true }
                )
            }
        }
    }
}

#Preview {
    MainView()
}
