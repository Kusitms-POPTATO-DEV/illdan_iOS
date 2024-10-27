//
//  TodayView.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/27/24.
//

import SwiftUI

struct TodayView: View {
    @ObservedObject private var viewModel = TodayViewModel()
    var goToBacklog: () -> Void
    
    var body: some View {
        ZStack {
            Color(.gray100)
                .ignoresSafeArea()
            
            VStack {
                TopBar(
                    titleText: viewModel.currentDate,
                    subText: ""
                )
                
                if viewModel.todayList.isEmpty {
                    EmptyTodayView(
                        goToBacklog: goToBacklog
                    )
                } else {
                    TodayListView(
                        todayList: $viewModel.todayList
                    )
                }
            }
        }
    }
}

struct TodayListView: View {
    @Binding var todayList: Array<TodayItemModel>
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(todayList.indices, id: \.self) { index in
                    TodayItemView(
                        item: $todayList[index]
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
