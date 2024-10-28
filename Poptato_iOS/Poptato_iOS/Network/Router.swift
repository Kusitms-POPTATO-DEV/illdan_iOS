//
//  Router.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/26/24.
//

import Foundation
import Alamofire

enum Router: URLRequestConvertible {
    // auth
    case kakaoLogin(loginRequest: KaKaoLoginRequest)
    case reissueToken(reissueRequest: TokenModel)
    
    // backlog
    case createBacklog(createBacklogRequest: CreateBacklogRequest)
    case getBacklogList(page: Int, size: Int)
    case deleteBacklog(todoId: Int)
    case editBacklog(todoId: Int, content: String)
    
    // today
    case getTodayList(page: Int, size: Int)
    
    // todo
    case swipeTodo(swipeRequest: TodoIdModel)
    
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
        // auth
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
            
        // backlog
        case .createBacklog(let createBacklogRequest):
            let endpoint = url.appendingPathComponent("/backlog")
            request = URLRequest(url: endpoint)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let accessToken = accessToken {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            request.httpBody = try JSONEncoder().encode(createBacklogRequest)
        case .getBacklogList(let page, let size):
            var components = URLComponents(url: url.appendingPathComponent("/backlogs"), resolvingAgainstBaseURL: false)
            components?.queryItems = [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "size", value: "\(size)")
            ]
            guard let endpoint = components?.url else {
                throw URLError(.badURL)
            }
            request = URLRequest(url: endpoint)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let accessToken = accessToken {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
        case .deleteBacklog(let todoId):
            let endpoint = url.appendingPathComponent("/todo/\(todoId)")
            request = URLRequest(url: endpoint)
            request.httpMethod = "DELETE"
            if let accessToken = accessToken {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
        case .editBacklog(let todoId, let content):
            let endpoint = url.appendingPathComponent("/todo/\(todoId)/content")
            request = URLRequest(url: endpoint)
            request.httpMethod = "PATCH"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let accessToken = accessToken {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            request.httpBody = try JSONEncoder().encode(TodoContentModel(content: content))
            
        // today
        case .getTodayList(let page, let size):
            var components = URLComponents(url: url.appendingPathComponent("/todays"), resolvingAgainstBaseURL: false)
            components?.queryItems = [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "size", value: "\(size)")
            ]
            guard let endpoint = components?.url else {
                throw URLError(.badURL)
            }
            request = URLRequest(url: endpoint)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let accessToken = accessToken {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            
        // todo
        case .swipeTodo(let swipeRequest):
            let endpoint = url.appendingPathComponent("/swipe")
            request = URLRequest(url: endpoint)
            request.httpMethod = "PATCH"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let accessToken = accessToken {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            request.httpBody = try JSONEncoder().encode(swipeRequest)
        }
    
        return request
    }
}
