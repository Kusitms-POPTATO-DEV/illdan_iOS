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
    var buttonType: DialogButtonType = DialogButtonType.double
    
    var onClickBtnPositive: () -> Void = {}
    var onClickBtnNegative: () -> Void = {}
    var onDismissRequest: () -> Void = {}
    
    var body: some View {
        ZStack(alignment: .center) {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismissRequest()
                }
            
            ZStack(alignment: .center) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 48)
                    if !title.isEmpty {
                        Text(title)
                            .font(PoptatoTypo.lgSemiBold)
                            .foregroundColor(.gray00)
                        Spacer().frame(height: 10)
                    }
                    Text(content)
                        .font(PoptatoTypo.mdRegular)
                        .foregroundColor(.gray40)
                        .multilineTextAlignment(.center)
                    Spacer().frame(height: 48)
                    
                    if buttonType == .double {
                        Rectangle().fill(Color.gray90).frame(maxWidth: .infinity).frame(height: 1)
                    }
                    
                    ZStack(alignment: .center) {
                        if buttonType == .single { Color.gray95 }
                        
                        Text(positiveButtonText)
                            .font(PoptatoTypo.lgSemiBold)
                            .foregroundStyle(buttonType == .double ? Color.warning40 : Color.gray10)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .contentShape(Rectangle())
                    .onTapGesture { onClickBtnPositive() }
                    
                    if buttonType == .double {
                        Rectangle().fill(Color.gray90).frame(maxWidth: .infinity).frame(height: 1)
                        
                        Text(negativeButtonText)
                            .font(PoptatoTypo.lgSemiBold)
                            .foregroundStyle(Color.gray40)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .contentShape(Rectangle())
                            .onTapGesture { onClickBtnNegative() }
                    }
                }
            }
            .frame(maxWidth: 328)
            .background(Color.gray100)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }
}
