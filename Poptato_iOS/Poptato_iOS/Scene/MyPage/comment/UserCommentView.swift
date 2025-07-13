//
//  UserCommentView.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 7/13/25.
//

import SwiftUI

struct UserCommentView: View {
    @EnvironmentObject var viewModel: MyPageViewModel
    
    let onClickBtnBack: () -> Void
    
    var body: some View {
        ZStack {
            Color.gray100
                .ignoresSafeArea()
                .onTapGesture {
                    UIApplication.shared.endEditing()
                }
            
            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: 28)
                
                UserCommentTopBar(onClickBtnBack: onClickBtnBack)
                
                Spacer().frame(height: 24)
                
                Text("내용")
                    .font(PoptatoTypo.mdSemiBold)
                    .foregroundStyle(Color.gray00)
                
                Spacer().frame(height: 8)
                
                RoundedCardTextField(
                    text: $viewModel.comment,
                    placeholder: "자유롭게 의견을 보내주세요.",
                    singleLine: false,
                    maxLines: 10,
                    minHeight: 240,
                    maxHeight: 240
                )
                
                Spacer().frame(height: 24)
                
                Text("연락처")
                    .font(PoptatoTypo.mdSemiBold)
                    .foregroundColor(Color.gray00)
                
                Spacer().frame(height: 8)

                RoundedCardTextField(
                    text: $viewModel.contact,
                    placeholder: "ex) simpleday.illdan@gmail.com",
                    singleLine: true,
                    maxLength: 30
                )
                
                Spacer().frame(height: 8)
                
                Text("* 답변이 필요하다면 이메일 or 연락처를 남겨주세요.")
                    .font(PoptatoTypo.smMedium)
                    .foregroundColor(Color.gray60)
                
                Spacer()
                
                Button(action: {
                    Task {
                        await viewModel.sendComment()
                    }
                }) {
                    Text("전송")
                        .font(PoptatoTypo.mdSemiBold)
                        .foregroundColor(Color.gray90)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.primary40)
                        .cornerRadius(12)
                }
                
                Spacer().frame(height: 16)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
        }
        .ignoresSafeArea(.keyboard)
        .onReceive(viewModel.eventPublisher) { event in
            switch event {
            case .sendCommentSuccess:
                viewModel.showSuccessToast = true
                onClickBtnBack()
            case .sendCommentFailure:
                viewModel.showFailureToast = true
            }
        }
        .toast(isPresented: $viewModel.showFailureToast, message: "전송에 실패했습니다.")
    }
}

private struct UserCommentTopBar: View {
    var onClickBtnBack: () -> Void
    
    var body: some View {
        ZStack(alignment: .center) {
            HStack {
                Button(
                    action: onClickBtnBack
                ) {
                    Image("ic_arrow_left")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.gray00)
                }
                
                Spacer()
            }
            
            Text("개발자에게 의견 보내기")
                .font(PoptatoTypo.mdSemiBold)
                .foregroundStyle(Color.gray00)
        }
        .frame(maxWidth: .infinity)
    }
}

struct RoundedCardTextField: View {
    @Binding var text: String
    
    let placeholder: String
    let singleLine: Bool
    let maxLines: Int
    let minHeight: CGFloat?
    let maxHeight: CGFloat?
    let maxLength: Int?
    
    init(
        text: Binding<String>,
        placeholder: String = "",
        singleLine: Bool = true,
        maxLines: Int = .max,
        minHeight: CGFloat? = nil,
        maxHeight: CGFloat? = nil,
        maxLength: Int? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.singleLine = singleLine
        self.maxLines = maxLines
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.maxLength = maxLength
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if singleLine {
                TextField("", text: $text)
                    .font(PoptatoTypo.mdRegular)
                    .foregroundColor(Color.gray00)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .onChange(of: text) { new in
                        if let maxLength = maxLength, new.count > maxLength {
                            text = String(new.prefix(maxLength))
                        }
                    }
            } else {
                InsetsTextView(
                  text: $text,
                  placeholder: placeholder,
                  maxLines: maxLines,
                  minHeight: minHeight,
                  maxHeight: maxHeight,
                  maxLength: maxLength
                )
                .frame(minHeight: minHeight, maxHeight: maxHeight)
            }
            
            if text.isEmpty {
                Text(placeholder)
                    .font(PoptatoTypo.mdRegular)
                    .foregroundColor(Color.gray40)
                    .padding(.horizontal, singleLine ? 20 : 16)
                    .padding(.vertical, singleLine ? 16 : 12)
                    .allowsHitTesting(false)
            }
        }
        .background(Color.gray95)
        .cornerRadius(12)
    }
}

struct InsetsTextView: UIViewRepresentable {
  @Binding var text: String
  let placeholder: String
  let maxLines: Int
  let minHeight: CGFloat?
  let maxHeight: CGFloat?
  let maxLength: Int?
  
  func makeUIView(context: Context) -> UITextView {
    let tv = UITextView()
    tv.delegate = context.coordinator
    tv.font = UIFont(name: PoptatoTypo.pretendardRegular, size: 16)
    tv.textColor = UIColor(Color.gray00)
    tv.backgroundColor = .clear
    tv.textContainerInset = UIEdgeInsets(
      top: 12,
      left: 16,
      bottom: 12,
      right: 16
    )
    tv.textContainer.lineFragmentPadding = 0
    tv.isScrollEnabled = true
    tv.showsVerticalScrollIndicator = false
    return tv
  }
  
  func updateUIView(_ uiView: UITextView, context: Context) {
    if uiView.text != text {
      uiView.text = text
    }
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, UITextViewDelegate {
    var parent: InsetsTextView
    init(_ parent: InsetsTextView) { self.parent = parent }
    
    func textViewDidChange(_ textView: UITextView) {
      var new = textView.text ?? ""
      if let maxLength = parent.maxLength, new.count > maxLength {
        new = String(new.prefix(maxLength))
        textView.text = new
      }
      parent.text = new
    }
  }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder),
                   to: nil, from: nil, for: nil)
    }
}
