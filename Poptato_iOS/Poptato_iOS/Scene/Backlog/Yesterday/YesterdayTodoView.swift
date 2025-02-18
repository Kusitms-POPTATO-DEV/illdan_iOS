//
//  YesterdayTodoView.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/11/24.
//

import SwiftUI

struct YesterdayTodoView: View {
    @ObservedObject private var viewModel = YesterdayTodoViewModel()
    @Binding var isYesterdayTodoViewPresented: Bool
    @Binding var isMotivationViewPresented: Bool
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.gray100.ignoresSafeArea()
            
            VStack {
                ZStack(alignment: .center) {
                    Text("어제 한 일을 모두 체크하세요!")
                        .font(PoptatoTypo.mdMedium)
                        .foregroundColor(.gray00)
                    HStack {
                        Spacer()
                        Image("ic_close")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .onTapGesture {
                                isYesterdayTodoViewPresented = false
                            }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                
                YesterdayListView(
                    yesterdayTodoList: $viewModel.yesterdayList,
                    addCompletionList: { id in
                        viewModel.addCompletionList(todoId: id)
                    }
                )
                
                Spacer()
                
                Button(action: {
                    isMotivationViewPresented = true
                    Task {
                        await viewModel.completeYesterdayTodo()
                    }
                    isYesterdayTodoViewPresented = false
                }) {
                    Text("완료")
                        .font(PoptatoTypo.lgSemiBold)
                        .foregroundColor(.gray100)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.primary60)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarBackButtonHidden()
        .onAppear {
            Task {
                await viewModel.getYesterdayList(page: 0, size: 100)
            }
        }
    }
}

struct YesterdayListView: View {
    @Binding var yesterdayTodoList: [YesterdayItemModel]
    var addCompletionList: (Int) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach($yesterdayTodoList, id: \.todoId) { $item in
                    YesterdayItemView(
                        item: $item,
                        addCompletionList: addCompletionList
                    )
                }
            }
        }
    }
}

struct YesterdayItemView: View {
    @Binding var item: YesterdayItemModel
    @State var isClicked: Bool = false
    var addCompletionList: (Int) -> Void
    
    var body: some View {
        HStack {
            Image(isClicked ? "ic_checked" : "ic_unchecked")
                .resizable()
                .frame(width: 20, height: 20)
                .onTapGesture {
                    isClicked.toggle()
                    addCompletionList(item.todoId)
                }

            Text(item.content)
                .font(PoptatoTypo.mdRegular)
                .foregroundColor(.gray00)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(RoundedRectangle(cornerRadius: 8))
        .foregroundColor(.gray95)
    }
}
