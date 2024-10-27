//
//  TodayRepositoryImpl.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/27/24.
//

final class TodayRepositoryImpl: TodayRepository {
    func getTodayList(page: Int, size: Int) async throws -> TodayListResponse {
        try await NetworkManager.shared.request(type: TodayListResponse.self, api: .getTodayList(page: page, size: size))
    }
}
