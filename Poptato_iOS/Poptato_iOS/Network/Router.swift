//
//  Router.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/26/24.
//

import Foundation
import Alamofire

enum Router: URLRequestConvertible {
    case kakaoLogin(loginRequest: KaKaoLoginRequest)
    case reissueToken(reissueRequest: TokenModel)
    
    var accessToken: String? {
        KeychainManager.shared.readToken(for: "accessToken")
    }
    var refreshToken: String? {
        KeychainManager.shared.readToken(for: "refreshToken")
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = URL(string: BASE_URL)!
        var request: URLRequest
        
        switch self {
        case .kakaoLogin(let loginRequest):
            let endPoint = url.appendingPathComponent("/auth/login")
            request = URLRequest(url: endPoint)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(loginRequest)
        case .reissueToken(let reissueRequest):
            let endPoint = url.appendingPathComponent("/auth/refresh")
            request = URLRequest(url: endPoint)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let accessToken = accessToken {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            request.httpBody = try JSONEncoder().encode(reissueRequest)
        }
    
        return request
    }
}
