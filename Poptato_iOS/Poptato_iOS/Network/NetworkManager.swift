//
//  NetworkManager.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/26/24.
//

import Foundation
import Alamofire

final class NetworkManager {

    static let shared = NetworkManager()

    private init() {}
    
    func request<T: Decodable>(type: T.Type, api: Router) async throws -> T {
        do {
            return try await performRequest(type: type, api: api)
        } catch {
            if case RequestError.unauthorized = error {
                await refreshToken()
                return try await performRequest(type: type, api: api)
            } else {
                throw error
            }
        }
    }
    
    private func performRequest<T: Decodable>(type: T.Type, api: Router) async throws -> T {
        let dataTask = try AF.request(api.asURLRequest()).serializingDecodable(ApiResponse<T>.self)
        await print(String(data: dataTask.response.data!, encoding: .utf8) ?? "데이터 없음")

        switch await dataTask.result {
        case .success(let apiResponse):
            print("result", apiResponse.result)
            return apiResponse.result
        case .failure(let error):
            if let responseCode = await dataTask.response.response?.statusCode, responseCode == 401 {
                throw RequestError.unauthorized
            }
            print("error", error)
            throw error
        }
    }

    func request(api: Router) async throws {
        do {
            try await performRequest(api: api)
        } catch {
            if case RequestError.unauthorized = error {
                await refreshToken()
                try await performRequest(api: api)
            } else {
                throw error
            }
        }
    }

    private func performRequest(api: Router) async throws {
        let req = try AF.request(api.asURLRequest()).serializingData()
        
        let data = await req.response.data
        print(String(data: data ?? Data(), encoding: .utf8) ?? "데이터 없음")

        switch await req.result {
        case .success:
            print("Request succeeded")
        case .failure(let error):
            if let responseCode = await req.response.response?.statusCode, responseCode == 401 {
                throw RequestError.unauthorized
            }
            print("error", error)
            throw error
        }
    }
    
    private func refreshToken() async {
        guard let accessToken = KeychainManager.shared.readToken(for: "accessToken") else { return }
        guard let refreshToken = KeychainManager.shared.readToken(for: "refreshToken") else { return }
        
        do {
            let response = try await AuthRepositoryImpl().refreshToken(request: TokenModel(accessToken: accessToken, refreshToken: refreshToken))
            KeychainManager.shared.saveToken(response.accessToken, for: "accessToken")
            KeychainManager.shared.saveToken(response.refreshToken, for: "refreshToken")
            print("토큰 갱신 성공")
        } catch {
            print("토큰 갱신 실패: \(error)")
        }
    }
}

enum RequestError: Error {
    case decode
    case invalidURL
    case noResponse
    case unauthorized
    case unexpectedStatusCode
    case unknown

    var customMessage: String {
        switch self {
        case .decode:
            return "Decode error"
        case .unauthorized:
            return "Session expired"
        default:
            return "Unknown error"
        }
    }
}
