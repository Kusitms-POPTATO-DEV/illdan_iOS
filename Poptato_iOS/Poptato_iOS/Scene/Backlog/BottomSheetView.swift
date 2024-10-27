//
//  BottomSheetView.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/26/24.
//

import SwiftUI

struct BottomSheetView: View {
    @Binding var isVisible: Bool
    var todoItem: TodoItemModel
    var deleteTodo: () -> Void
    var editTodo: () -> Void
    
    var body: some View {
        VStack {
            Spacer()

            VStack {
                HStack {
                    Text(todoItem.content)
                        .font(PoptatoTypo.xLMedium)
                        .foregroundColor(.gray00)
                        .lineLimit(1)
                    Spacer()
                    if todoItem.bookmark {
                        Image("ic_star_filled")
                            .resizable()
                            .frame(width: 20, height: 20)
                    } else {
                        Image("ic_star_empty")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                HStack {
                    Button(
                        action: {
                            editTodo()
                            isVisible = false
                        }
                    ) {
                        Text("수정")
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .foregroundColor(.gray40)
                            .background(Color(.gray95))
                            .cornerRadius(8)
                    }
                    
                    Button(
                        action: {
                            deleteTodo()
                            isVisible = false
                        }
                    ) {
                        Text("삭제")
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .foregroundColor(.danger40)
                            .cornerRadius(8)
                            .background(Color(.danger40).opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
                
                Divider()
                    .background(Color(.gray95))
                
                HStack {
                    if todoItem.deadline == nil {
                        Image("ic_plus")
                    } else {
                        Image("ic_minus")
                    }
                    
                    Text("마감기한")
                        .font(PoptatoTypo.mdMedium)
                        .foregroundColor(.gray40)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                
                Divider()
                    .background(Color(.gray95))
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .background(Color(UIColor.gray100))
            .clipShape(RoundedCorner(radius: 16, corners: [.topLeft, .topRight]))
        }
        .background(Color(UIColor.gray100).opacity(0.6)
            .onTapGesture {
                isVisible = false
            }
        )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 16
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    
    BottomSheetView(
        isVisible: .constant(true),
        todoItem: TodoItemModel(
            todoId: 1,
            content: "테스트테스트테스트테스트테스트테스트테스트테스트",
            bookmark: false,
            dDay: nil,
            deadline: nil
        ),
        deleteTodo: {},
        editTodo: {}
    )
}
