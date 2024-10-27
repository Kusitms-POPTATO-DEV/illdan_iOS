//
//  TodayRepository.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/27/24.
//

protocol TodayRepository {
    func getTodayList(page: Int, size: Int) async throws -> TodayListResponse
}
