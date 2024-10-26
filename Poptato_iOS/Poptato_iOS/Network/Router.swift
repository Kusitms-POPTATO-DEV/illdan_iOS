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
    
    func asURLRequest() throws -> URLRequest {
        let url = URL(string: BASE_URL)!
        var request: URLRequest
        
        switch self {
        case .kakaoLogin(let loginRequest):
            let loginURL = url.appendingPathComponent("/auth/login")
            request = URLRequest(url: loginURL)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(loginRequest)
        }
        
        return request
    }
}
