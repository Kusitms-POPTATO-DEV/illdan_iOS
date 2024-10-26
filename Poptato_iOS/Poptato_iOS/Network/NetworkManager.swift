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

        let dataTask = try AF.request(api.asURLRequest()).serializingDecodable(ApiResponse<T>.self)
        await print(String(data: dataTask.response.data!, encoding: .utf8) ?? "데이터 없음")

        switch await dataTask.result {
        case .success(let apiResponse):
            guard let response = await dataTask.response.response else {
                throw RequestError.unknown
            }
            print("result", apiResponse.result)
            return apiResponse.result
        case .failure(let error):
            print("error", error)
            throw error
        }
    }

    func request(api: Router) async throws {
        let req = try AF.request(api.asURLRequest())
        print(req.response?.statusCode ?? -1)
        req.response { data in 
            print("request data", data)
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
