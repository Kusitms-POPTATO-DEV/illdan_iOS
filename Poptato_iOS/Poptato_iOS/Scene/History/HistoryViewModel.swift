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
    @Published var historyList: [HistoryListItemModel] = []
    @Published var monthlyHistory: [HistoryCalendarItem] = []
    
    private var historyMap: [String: HistoryCalendarItem] = [:]
    
    private var historyRepository: HistoryRepository
    
    init(historyRepository: HistoryRepository = HistoryRepositoryImpl()) {
        let currentDate = Date()
        let calendar = Calendar.current

        self.year = calendar.component(.year, from: currentDate)
        self.month = calendar.component(.month, from: currentDate)
        self.historyRepository = historyRepository
        self.day = calendar.component(.day, from: currentDate)
        selectedDay = self.day
    }
    
    func initializeHistory() async {
        if let day = selectedDay {
            let formattedMonth = String(format: "%02d", month)
            let formattedDay = String(format: "%02d", day)
            await getHistory(date: "\(year)-\(formattedMonth)-\(formattedDay)")
        }
    }

    func onClickIncreaseMonth() {
        if (month == 12) {
            month = 1
            year += 1
        } else {
            month += 1
        }
        generateCalendarDays()
        Task {
            await initializeHistory()
            await getMonthlyHistory()
        }
    }
    
    func onClickDecreaseMonth() {
        if (month == 1) {
            month = 12
            year -= 1
        } else {
            month -= 1
        }
        generateCalendarDays()
        Task {
            await initializeHistory()
            await getMonthlyHistory()
        }
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
    
    func getHistory(date: String) async {
        do {
            let response = try await historyRepository.getHistory(date: date)
            
            await MainActor.run {
                historyList = response.histories
            }
        } catch {
            print("Error getHistory: \(error)")
        }
    }
    
    func getMonthlyHistory() async {
        do {
            let response = try await historyRepository.getMonthlyHistory(year: String(year), month: month)
            await MainActor.run {
                monthlyHistory = response.historyCalendarList
                historyMap = Dictionary(uniqueKeysWithValues: monthlyHistory.map { ($0.date, $0) })
            }
        } catch {
            print("Error getMonthlyHistory: \(error)")
        }
    }
    
    func historyItem(for date: String) -> HistoryCalendarItem? {
        historyMap[date]
    }
}
