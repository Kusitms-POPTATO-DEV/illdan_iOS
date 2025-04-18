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
            
            VStack(spacing: 0) {
                Spacer().frame(height: 8)
                
                DateNavigatorView(
                    year: viewModel.year,
                    month: viewModel.month,
                    onClickIncreaseMonth: viewModel.onClickIncreaseMonth,
                    onClickDecreaseMonth: viewModel.onClickDecreaseMonth
                )
                
                Spacer().frame(height: 12)
                
                CalendarView(
                    days: viewModel.days,
                    selectedDay: $viewModel.selectedDay,
                    getHistory: {
                        Task {
                            await viewModel.initializeHistory()
                        }
                    },
                    monthlyHistory: viewModel.monthlyHistory,
                    currentYear: viewModel.year,
                    currentMonth: viewModel.month,
                    getHistoryItem: { date in viewModel.historyItem(for: date) }
                )
                
                Spacer().frame(height: 16)
                
                HistoryListView(historyList: viewModel.historyList)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            Task {
                await viewModel.initializeHistory()
                await viewModel.getMonthlyHistory()
            }
            viewModel.generateCalendarDays()
        }
    }
}

struct CalendarView: View {
    var days: [Int?]
    @Binding var selectedDay: Int?
    var getHistory: () -> Void
    var monthlyHistory: [HistoryCalendarItem]
    var currentYear: Int
    var currentMonth: Int
    var getHistoryItem: (String) -> HistoryCalendarItem?
    
    var body: some View {
        VStack {
            HStack {
                ForEach(["일", "월", "화", "수", "목", "금", "토"], id: \.self) { day in
                    Text(day)
                        .font(PoptatoTypo.xsMedium)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.gray00)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 24)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(Array(days.enumerated()), id: \.offset) { index, date in
                    if let date = date {
                        let formattedDate = String(format: "%04d-%02d-%02d", currentYear, currentMonth, date)
                        let item = getHistoryItem(formattedDate)
                        
                        VStack(spacing: 0) {
                            ZStack {
                                if let item = item {
                                    if item.count == -1 {
                                        Image("ic_fire_calendar")
                                            .resizable()
                                            .frame(width: 32, height: 32)
                                    } else {
                                        ZStack(alignment: .center) {
                                            Image("ic_empty_fire_calendar")
                                                .resizable()
                                                .frame(width: 32, height: 32)
                                            
                                            Text("\(item.count)")
                                                .font(PoptatoTypo.xsMedium)
                                                .foregroundStyle(Color.gray00)
                                                .padding(.top, 2)
                                        }
                                    }
                                } else {
                                    Image("ic_empty_fire_calendar")
                                        .resizable()
                                        .frame(width: 32, height: 32)
                                }
                            }
                            
                            Spacer().frame(height: 4)
                            
                            Text("\(date)")
                                .font(PoptatoTypo.xsMedium)
                                .foregroundColor(selectedDay == date ? Color.gray90 : Color.gray10)
                                .padding(4)
                                .background(
                                    Circle()
                                        .fill(selectedDay == date ? Color.gray00 : Color.gray95)
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
        .padding(.vertical, 16)
        .background(Color.gray95)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 20)
    }
}

struct HistoryListView: View {
    var historyList: [HistoryListItemModel]
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(historyList, id: \.todoId) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Image(item.isCompleted ? "ic_checked" : "ic_unchecked")
                            .resizable()
                            .frame(width: 16, height: 16)
                        Text(item.content)
                            .font(PoptatoTypo.smRegular)
                            .foregroundColor(.gray10)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(historyList.isEmpty ? Color.gray100 : Color.gray95)
            .clipShape(RoundedCorner(radius: 12))
            .padding(.horizontal, 20)
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
            Text("\(String(format: "%d", year))년 \(String(format: "%2d", month))월")
                .font(PoptatoTypo.xLSemiBold)
                .foregroundColor(.gray00)
            
            Spacer()
            
            Button(action: {
                onClickDecreaseMonth()
            }) {
                Image("ic_arrow_left")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.gray00)
            }
            
            Spacer().frame(width: 12)
            
            Button(action: {
                onClickIncreaseMonth()
            }) {
                Image("ic_arrow_right")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.gray00)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }
}
