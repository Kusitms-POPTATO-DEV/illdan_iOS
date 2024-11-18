//
//  HistoryView.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/15/24.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject private var viewModel = HistoryViewModel()
    
    var body: some View {
        ZStack {
            Color.gray100.ignoresSafeArea()
            
            VStack {
                Spacer().frame(height: 8)
                
                DateNavigatorView(
                    year: viewModel.year,
                    month: viewModel.month,
                    onClickIncreaseMonth: viewModel.onClickIncreaseMonth,
                    onClickDecreaseMonth: viewModel.onClickDecreaseMonth
                )
                
                CalendarView(
                    days: viewModel.days,
                    selectedDay: $viewModel.selectedDay,
                    getHistory: {
                        Task {
                            await viewModel.initializeHistory()
                        }
                    }
                )
                
                Spacer().frame(height: 36)
                
                HistoryListView(historyList: viewModel.historyList)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct CalendarView: View {
    var days: [Int?]
    @Binding var selectedDay: Int?
    var getHistory: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                ForEach(["일", "월", "화", "수", "목", "금", "토"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 14, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.gray70)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 24)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(Array(days.enumerated()), id: \.offset) { index, date in
                    if let date = date {
                        VStack(spacing: 0) {
                            Image("ic_empty_emoji")
                                .resizable()
                                .frame(width: 32, height: 32)
                            
                            Spacer().frame(height: 4)
                            
                            Text("\(date)")
                                .font(PoptatoTypo.calRegular)
                                .foregroundColor(.gray70)
                                .padding(4)
                                .background(
                                    Circle()
                                        .fill(selectedDay == date ? Color.gray00 : Color.gray100)
                                )
                        }
                        .onTapGesture {
                            selectedDay = date
                            getHistory()
                        }
                    } else {
                        Text("")
                            .frame(width: 32, height: 32)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

struct HistoryListView: View {
    var historyList: [HistoryListItemModel]
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(historyList, id: \.todoId) { item in
                    HStack(spacing: 8) {
                        Image("ic_history_checkbox")
                        Text(item.content)
                            .font(PoptatoTypo.smMedium)
                            .foregroundColor(.gray00)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
        }
    }
}

struct DateNavigatorView: View {
    var year: Int
    var month: Int
    var onClickIncreaseMonth: () -> Void
    var onClickDecreaseMonth: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: {
                onClickDecreaseMonth()
            }) {
                Image("ic_arrow_left")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.gray40)
            }
            
            Text("\(String(format: "%d", year))년 \(String(format: "%2d", month))월")
                .font(PoptatoTypo.mdMedium)
                .foregroundColor(.gray00)
                .frame(maxWidth: .infinity)
            
            Button(action: {
                onClickIncreaseMonth()
            }) {
                Image("ic_arrow_right")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.gray40)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 46)
    }
}
