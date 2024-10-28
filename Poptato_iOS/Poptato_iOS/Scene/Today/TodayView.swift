//
//  TodayView.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/27/24.
//

import SwiftUI

struct TodayView: View {
    @EnvironmentObject var viewModel: TodayViewModel
    var goToBacklog: () -> Void
    @State private var isViewActive = false
    
    var body: some View {
        ZStack {
            Color(.gray100)
                .ignoresSafeArea()
            
            VStack {
                TopBar(
                    titleText: viewModel.currentDate,
                    subText: ""
                )
                
                if isViewActive {
                    if viewModel.todayList.isEmpty {
                        EmptyTodayView(
                            goToBacklog: goToBacklog
                        )
                    } else {
                        TodayListView(
                            todayList: $viewModel.todayList,
                            swipeToday: { id in
                                Task {
                                    await viewModel.swipeToday(todoId: id)
                                }
                            }
                        )
                    }
                }
            }
        }
        .onAppear {
            Task {
                isViewActive = true
                await viewModel.getTodayList()
            }
        }
        .onDisappear {
            isViewActive = false
        }
    }
}

struct TodayListView: View {
    @Binding var todayList: Array<TodayItemModel>
    var swipeToday: (Int) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(todayList.indices, id: \.self) { index in
                    TodayItemView(
                        item: $todayList[index],
                        todayList: $todayList,
                        swipeToday: swipeToday
                    )
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
    }
}

struct TodayItemView: View {
    @Binding var item: TodayItemModel
    @Binding var todayList: Array<TodayItemModel>
    var swipeToday: (Int) -> Void
    @State private var offset: CGFloat = 0
    
    var body: some View {
        VStack {
            HStack{
                Image(item.todayStatus == "COMPLETED" ? "ic_checked" : "ic_unchecked")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .onTapGesture {
                        switch item.todayStatus {
                        case "COMPLETED":
                            item.todayStatus = "INCOMPLETE"
                        case "INCOMPLETE":
                            item.todayStatus = "COMPLETED"
                        default: break
                        }
                    }
                
                Text(item.content)
                    .font(PoptatoTypo.mdRegular)
                    .foregroundColor(.gray00)
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 8))
        .foregroundColor(.gray95)
        .offset(x: offset)
        .simultaneousGesture(
            DragGesture(minimumDistance: 20)
                .onChanged { gesture in
                    if gesture.translation.width > 0 {
                        self.offset = gesture.translation.width
                    }
                }
                .onEnded { _ in
                    if abs(offset) > 100 {
                        swipeToday(item.todoId)
                        withAnimation {
                            self.offset = UIScreen.main.bounds.width
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            if let index = todayList.firstIndex(where: { $0.todoId == item.todoId }) {
                                todayList.remove(at: index)
                            }
                            offset = 0
                        }
                    } else {
                        withAnimation {
                            offset = 0
                        }
                    }
                }
        )
    }
}

struct EmptyTodayView: View {
    var goToBacklog: () -> Void
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack {
                Text("오늘 할 일은 무엇인가요?")
                    .font(PoptatoTypo.lgMedium)
                    .foregroundColor(.gray40)
                
                Button(
                    action: { goToBacklog() }
                ) {
                    HStack {
                        Image("ic_backlog_unselected")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.primary100)
                        
                        Text("할 일 가져오기")
                            .font(PoptatoTypo.smSemiBold)
                            .foregroundColor(.primary100)
                    }
                    .frame(width: 132, height: 37)
                    .background(Color(.primary60))
                    .cornerRadius(32)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    TodayView(
        goToBacklog: {}
    )
}
