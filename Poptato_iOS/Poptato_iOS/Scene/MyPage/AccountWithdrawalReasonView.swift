//
//  AccountWithdrawalReasonView.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 4/18/25.
//

import SwiftUI

struct AccountWithdrawalReasonView: View {
    @Binding var selectedReasons: [Bool]
    @Binding var userInputReason: String
    @FocusState var isFocused: Bool
    
    var onClickBtnClose: () -> Void
    var showGoodbyeView: () -> Void
    
    @State private var showAccountDeletionDialog = false
    
    var body: some View {
        ZStack {
            Color.gray100.ignoresSafeArea().onTapGesture {
                isFocused = false
            }
            
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer().frame(height: 28)
                        
                        HStack {
                            Spacer()
                            
                            Button(action: onClickBtnClose) {
                                Image("ic_close")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundStyle(Color.gray00)
                                    .frame(width: 24, height: 24)
                            }
                        }
                        
                        Text("탈퇴하시는\n이유는 무엇인가요?")
                            .font(PoptatoTypo.xxLSemiBold)
                            .foregroundStyle(Color.gray00)
                            .multilineTextAlignment(.leading)
                        
                        Spacer().frame(height: 8)
                        
                        Text("답변해주신 내용을 바탕으로 더 좋은 서비스를\n만들기 위해 노력하겠습니다.")
                            .font(PoptatoTypo.mdRegular)
                            .foregroundStyle(Color.gray00)
                            .multilineTextAlignment(.leading)
                        
                        Spacer().frame(height: 24)
                        
                        ForEach(0..<3, id: \.self) { index in
                            switch(index) {
                            case 0:
                                WithdrawalReasonView(isChecked: $selectedReasons[index], title: "자주 사용하지 않아요")
                                Spacer().frame(height: 16)
                            case 1:
                                WithdrawalReasonView(isChecked: $selectedReasons[index], title: "원하는 기능이 없어요")
                                Spacer().frame(height: 16)
                            case 2:
                                WithdrawalReasonView(isChecked: $selectedReasons[index], title: "과정이 너무 복잡해요")
                                Spacer().frame(height: 16)
                            default:
                                EmptyView()
                            }
                        }
                        
                        UserInputReasonTextField(isFocused: $isFocused, userInput: $userInputReason)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 20)
                }
                
                Button(action: { showAccountDeletionDialog = true }) {
                    Text("탈퇴하기")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14.5)
                        .background(Color.gray95)
                        .clipShape(RoundedCorner(radius: 16))
                        .font(PoptatoTypo.lgSemiBold)
                        .foregroundStyle(Color.gray70)
                }
                .padding(.horizontal, 20)
                .scrollDismissesKeyboard(.never)
            }
            
            if showAccountDeletionDialog {
                CommonDialog(
                    title: "정말 탈퇴하시겠어요?",
                    content: "탈퇴 시 계정에 저장된 모든 데이터가\n삭제되며, 복구되지 않아요.",
                    positiveButtonText: "탈퇴하기",
                    negativeButtonText: "취소",
                    onClickBtnPositive: {
                        showAccountDeletionDialog = false
                        onClickBtnClose()
                        showGoodbyeView()
                    },
                    onClickBtnNegative: { showAccountDeletionDialog = false },
                    onDismissRequest: { showAccountDeletionDialog = false }
                )
            }
        }
        .ignoresSafeArea(.keyboard)
        .simultaneousGesture(
            TapGesture().onEnded {
                isFocused = false
            }
        )
    }
}

struct WithdrawalReasonView: View {
    @Binding var isChecked: Bool
    let title: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(isChecked ? "ic_checked" : "ic_unchecked")
                .resizable()
                .frame(width: 20, height: 20)
                .onTapGesture {
                    isChecked.toggle()
                }
            
            Text(title)
                .font(PoptatoTypo.smMedium)
                .foregroundStyle(Color.gray00)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 17.5)
        .padding(.horizontal, 20)
        .background(Color.gray95)
        .clipShape(RoundedCorner(radius: 12))
    }
}

struct UserInputReasonTextField: View {
    @FocusState.Binding var isFocused: Bool
    @Binding var userInput: String
    
    var body: some View {
        ZStack {
            TextField("", text: $userInput, axis: .vertical)
                .focused($isFocused)
                .font(PoptatoTypo.mdRegular)
                .foregroundColor(.gray00)
                .onChange(of: userInput) { newValue in
                    if newValue.contains("\n") {
                        userInput = newValue.replacingOccurrences(of: "\n", with: "")
                        handleSubmit()
                    }
                }
            
            if userInput.isEmpty {
                Text("직접 입력하기...")
                    .font(PoptatoTypo.smMedium)
                    .foregroundStyle(Color.gray60)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .highPriorityGesture(
                        TapGesture().onEnded {
                            isFocused.toggle()
                        }
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 17.5)
        .background(RoundedRectangle(cornerRadius: 12))
        .foregroundColor(.gray95)
    }
    
    private func handleSubmit() {
        isFocused = false
    }
}
