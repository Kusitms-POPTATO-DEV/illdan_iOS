//
//  AppStyle.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 4/16/25.
//

import SwiftUI

struct SmallToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            RoundedRectangle(cornerRadius: 12)
                .fill(configuration.isOn ? Color.primary40 : Color.gray80)
                .frame(width: 40, height: 24)
                .overlay(
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                        .offset(x: configuration.isOn ? 8 : -8)
                        .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
                )
        }
    }
}
