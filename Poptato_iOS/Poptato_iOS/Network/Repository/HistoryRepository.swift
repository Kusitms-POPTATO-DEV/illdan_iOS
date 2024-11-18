//
//  HistoryRepository.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/18/24.
//

protocol HistoryRepository {
    func getHistory(date: String) async throws -> HistoryListModel
}
