//
//  HistoryViewModel.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/15/24.
//

import SwiftUI

final class HistoryViewModel: ObservableObject {
    @Published var year: Int = 0
    @Published var month: Int = 0
    @Published var day: Int = 0
    @Published var days: [Int?] = []
    @Published var selectedDay: Int? = nil
    @Published var historyList: [HistoryListItemModel] = [ HistoryListItemModel(todoId: 1, content: "Test"), HistoryListItemModel(todoId: 2, content: "Test") ]
    
    init() {
        let currentDate = Date()
        let calendar = Calendar.current

        self.year = calendar.component(.year, from: currentDate)
        self.month = calendar.component(.month, from: currentDate)
        self.day = calendar.component(.day, from: currentDate)
        selectedDay = self.day
        generateCalendarDays()
    }

    func onClickIncreaseMonth() {
        if (month == 12) {
            month = 1
            year += 1
        } else {
            month += 1
        }
        generateCalendarDays()
    }
    
    func onClickDecreaseMonth() {
        if (month == 1) {
            month = 12
            year -= 1
        } else {
            month -= 1
        }
        generateCalendarDays()
    }
    
    func generateCalendarDays() {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: year, month: month)
        guard let firstDayOfMonth = calendar.date(from: dateComponents) else { return }
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)

        days = Array(repeating: nil, count: weekday - 1)

        if let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) {
            days += range.map { Optional($0) }
        }
    }
}
