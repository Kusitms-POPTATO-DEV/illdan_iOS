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
                    },
                    monthlyHistory: viewModel.monthlyHistory,
                    currentYear: viewModel.year,
                    currentMonth: viewModel.month
                )
                
                Spacer().frame(height: 36)
                
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
    var monthlyHistory: [String]
    var currentYear: Int
    var currentMonth: Int
    
    var body: some View {
        let today = Date()
        let calendar = Calendar.current

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
                        
                        VStack(spacing: 0) {
                            ZStack {
                                Image(
                                    monthlyHistory.contains(formattedDate) ? "ic_fire_calendar" : "ic_empty_fire_calendar"
                                )
                                .resizable()
                                .frame(width: 32, height: 32)
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
