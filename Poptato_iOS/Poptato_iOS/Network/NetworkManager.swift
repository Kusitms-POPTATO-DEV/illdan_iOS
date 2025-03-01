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
        let request = try api.asURLRequest()
        
        print("""
            [API 요청] \(api)
            [URL] \(request.url?.absoluteString ?? "URL 없음")
            [HTTP Method] \(request.httpMethod ?? "METHOD 없음")
            [헤더] \(request.allHTTPHeaderFields ?? [:])
            [요청 Body]
            \(prettyPrintedJSON(data: request.httpBody))
        """)
        
        let dataTask = try AF.request(api.asURLRequest()).serializingDecodable(ApiResponse<T>.self)
        let responseData = await dataTask.response.data
        print(String(data: responseData ?? Data(), encoding: .utf8) ?? "데이터 없음")

        if let responseData = responseData,
           let jsonObject = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
           let errorCode = jsonObject["code"] as? String {
            if errorCode == "AUTH-002" {
                throw RequestError.unauthorized
            } else if errorCode == "AUTH-008" {
                throw RequestError.invalidToken
            }
        }
        
        switch await dataTask.result {
        case .success(let apiResponse):
//            print("result", apiResponse.result)
            if let data = responseData {
                print(prettyPrintedJSON(data: data))
            }
            return apiResponse.result
        case .failure(let error):
            print("""
            [에러 타입] \(error.localizedDescription)
            [상세 에러] \(error)
            """)
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
        let request = try api.asURLRequest()
        
        print("""
            [API 요청] \(api)
            [URL] \(request.url?.absoluteString ?? "URL 없음")
            [HTTP Method] \(request.httpMethod ?? "METHOD 없음")
            [헤더] \(request.allHTTPHeaderFields ?? [:])
            [요청 Body]
            \(prettyPrintedJSON(data: request.httpBody))
        """)
        
        let req = try AF.request(api.asURLRequest()).serializingData()
        let data = await req.response.data
        print(String(data: data ?? Data(), encoding: .utf8) ?? "데이터 없음")

        if let data = data,
           let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let errorCode = jsonObject["code"] as? String {
            if errorCode == "AUTH-002" {
                throw RequestError.unauthorized
            } else if errorCode == "AUTH-003" {
                throw RequestError.invalidToken 
            }
        }

        switch await req.result {
        case .success:
            print("Request succeeded")
        case .failure(let error):
            print("""
            [에러 타입] \(error.localizedDescription)
            [상세 에러] \(error)
            """)
            throw error
        }
    }
    
    @discardableResult
    func refreshToken() async -> Bool {
        guard let accessToken = KeychainManager.shared.readToken(for: "accessToken") else { return false }
        guard let refreshToken = KeychainManager.shared.readToken(for: "refreshToken") else { return false }

        do {
            guard let fcmToken = try await FCMManager.shared.getFCMToken() else {
                print("FCM 토큰을 가져오지 못함.")
                return false
            }
            let request = ReissueTokenRequest(accessToken: accessToken, refreshToken: refreshToken, clientId: fcmToken)
            let response = try await AuthRepositoryImpl().refreshToken(request: request)
            
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
    
    private func prettyPrintedJSON(data: Data?) -> String {
        guard let data = data,
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
              let jsonString = String(data: prettyData, encoding: .utf8) else {
            return "Body 없음"
        }
        return jsonString
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
