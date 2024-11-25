//
//  HistoryRepositoryImpl.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/18/24.
//

final class HistoryRepositoryImpl: HistoryRepository {
    func getHistory(date: String) async throws -> HistoryListModel {
        try await NetworkManager.shared.request(type: HistoryListModel.self, api: .getHistory(date: date))
    }
    
    func getMonthlyHistory(year: String, month: Int) async throws -> HistoryCalendarResponse {
        try await NetworkManager.shared.request(type: HistoryCalendarResponse.self, api: .getMonthlyHistory(year: year, month: month))
    }
}
