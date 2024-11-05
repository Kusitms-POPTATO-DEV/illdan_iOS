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
                let isRefreshed = await refreshToken()
                if isRefreshed {
                    return try await performRequest(type: type, api: api)
                } else {
                    print("Token refresh failed, handle token expiry")
                    throw RequestError.invalidToken
                }
            } else {
                throw error
            }
        }
    }
    
    private func performRequest<T: Decodable>(type: T.Type, api: Router) async throws -> T {
        let dataTask = try AF.request(api.asURLRequest()).serializingDecodable(ApiResponse<T>.self)
        let responseData = await dataTask.response.data
        print(String(data: responseData ?? Data(), encoding: .utf8) ?? "데이터 없음")

        if let responseData = responseData,
           let jsonObject = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
           let errorCode = jsonObject["code"] as? Int {
            if errorCode == 6001 {
                throw RequestError.unauthorized
            } else if errorCode == 6002 {
                throw RequestError.invalidToken
            }
        }
        
        switch await dataTask.result {
        case .success(let apiResponse):
            print("result", apiResponse.result)
            return apiResponse.result
        case .failure(let error):
            print("error", error)
            throw error
        }
    }

    func request(api: Router) async throws {
        do {
            try await performRequest(api: api)
        } catch {
            if case RequestError.unauthorized = error {
                let isRefreshed = await refreshToken()
                if isRefreshed {
                    try await performRequest(api: api)
                } else {
                    print("Token refresh failed, handle token expiry")
                    throw RequestError.invalidToken
                }
            } else {
                throw error
            }
        }
    }

    private func performRequest(api: Router) async throws {
        let req = try AF.request(api.asURLRequest()).serializingData()
        let data = await req.response.data
        print(String(data: data ?? Data(), encoding: .utf8) ?? "데이터 없음")

        if let data = data,
           let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let errorCode = jsonObject["code"] as? Int {
            if errorCode == 6001 {
                throw RequestError.unauthorized
            } else if errorCode == 6002 {
                throw RequestError.invalidToken 
            }
        }

        switch await req.result {
        case .success:
            print("Request succeeded")
        case .failure(let error):
            print("error", error)
            throw error
        }
    }
    
    @discardableResult
    func refreshToken() async -> Bool {
        guard let accessToken = KeychainManager.shared.readToken(for: "accessToken") else { return false }
        guard let refreshToken = KeychainManager.shared.readToken(for: "refreshToken") else { return false }

        do {
            let response = try await AuthRepositoryImpl().refreshToken(request: TokenModel(accessToken: accessToken, refreshToken: refreshToken))
            KeychainManager.shared.saveToken(response.accessToken, for: "accessToken")
            KeychainManager.shared.saveToken(response.refreshToken, for: "refreshToken")
            print("토큰 갱신 성공")
            return true
        } catch {
            if let responseCode = (error as? AFError)?.responseCode, responseCode == 400 {
                print("400 에러 발생, 로그인 필요")
                return false
            }
            print("토큰 갱신 실패: \(error)")
            return false
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
    case invalidToken

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
