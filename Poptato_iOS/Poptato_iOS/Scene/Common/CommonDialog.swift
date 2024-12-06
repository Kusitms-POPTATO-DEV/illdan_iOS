//
//  CommonDialog.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/9/24.
//

import SwiftUI

struct CommonDialog: View {
    var title: String = ""
    var content: String = ""
    var positiveButtonText: String = ""
    var negativeButtonText: String = ""
    var onClickBtnPositive: () -> Void
    var onClickBtnNegative: () -> Void
    var onDismissRequest: () -> Void
    
    var body: some View {
        ZStack(alignment: .center) {
            Color.gray100.opacity(0.5)
            
            ZStack(alignment: .center) {
                Color.gray100.ignoresSafeArea()
                
                VStack {
                    Spacer()
                    if !title.isEmpty {
                        Text(title)
                            .font(PoptatoTypo.lgSemiBold)
                            .foregroundColor(.gray00)
                        Spacer().frame(height: 16)
                    }
                    Text(content)
                        .font(PoptatoTypo.mdSemiBold)
                        .foregroundColor(.gray00)
                        .multilineTextAlignment(.center)
                    Spacer()
                    HStack(spacing: 0) {
                        ZStack {
                            Color.gray95
                            
                            Text(negativeButtonText)
                                .font(PoptatoTypo.mdSemiBold)
                                .foregroundColor(.gray05)
                        }
                        .frame(height: 56)
                        .onTapGesture { onClickBtnNegative() }
                        
                        ZStack {
                            Color.danger50
                            
                            Text(positiveButtonText)
                                .font(PoptatoTypo.mdSemiBold)
                                .foregroundColor(.gray100)
                        }
                        .frame(height: 56)
                        .onTapGesture { onClickBtnPositive() }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                }
            }
            .cornerRadius(16)
            .frame(maxWidth: 328, maxHeight: 160)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            onDismissRequest()
        }
    }
}
