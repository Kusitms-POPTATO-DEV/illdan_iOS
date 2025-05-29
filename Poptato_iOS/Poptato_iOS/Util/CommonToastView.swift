//
//  CommonToastView.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 2/3/25.
//

import SwiftUI

struct CommonToastView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(PoptatoTypo.smMedium)
            .foregroundColor(.gray00)
            .padding(.horizontal, 16)
    }
}

struct ToastModifier: ViewModifier {
    @State private var dismissWorkItem: DispatchWorkItem?
    
    @Binding var isPresented: Bool
    
    let message: String
    let duration: Double

    func body(content: Content) -> some View {
        ZStack {
            content

            if isPresented {
                VStack {
                    Spacer()
                    HStack {
                        CommonToastView(message: message)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 8)
                    .frame(maxWidth: UIScreen.main.bounds.width - 16, alignment: .leading)
                    .background(
                        RoundedCorner(radius: 8)
                            .fill(Color.toast)
                    )
                    .transition(.opacity)
                    .transaction { transaction in
                        transaction.animation = nil
                    }
                    .padding(.bottom, 70)
                }
                .onAppear {
                    dismissWorkItem?.cancel()
                    
                    let task = DispatchWorkItem {
                        withAnimation {
                            isPresented = false
                        }
                    }
                    
                    dismissWorkItem = task
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: task)
                }
            }
        }
    }
}

extension View {
    func toast(isPresented: Binding<Bool>, message: String, duration: Double = 2.0) -> some View {
        self.modifier(ToastModifier(isPresented: isPresented, message: message, duration: duration))
    }
}
