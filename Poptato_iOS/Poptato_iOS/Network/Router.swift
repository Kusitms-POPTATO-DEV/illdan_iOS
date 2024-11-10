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
    case logout
    case deleteAccount
    
    // backlog
    case createBacklog(createBacklogRequest: CreateBacklogRequest)
    case getBacklogList(page: Int, size: Int)
    case deleteBacklog(todoId: Int)
    case editBacklog(todoId: Int, content: String)
    case updateDeadline(updateRequest: UpdateDeadlineRequest, todoId: Int)
    
    // today
    case getTodayList(page: Int, size: Int)
    
    // yesterday
    case getYesterdayList(page: Int, size: Int)
    
    // todo
    case swipeTodo(swipeRequest: TodoIdModel)
    case updateTodoCompletion(todoId: Int)
    case updateBookmark(todoId: Int)
    case dragAndDrop(type: String, todoIds: Array<Int>)
    
    // mypage
    case getUserInfo
    case getPolicy
    
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
        case .logout:
            let endpoint = url.appendingPathComponent("/auth/logout")
            request = URLRequest(url: endpoint)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let accessToken = accessToken {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
        case .deleteAccount:
            let endpoint = url.appendingPathComponent("/user")
            request = URLRequest(url: endpoint)
            request.httpMethod = "DELETE"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let accessToken = accessToken {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            
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
        case .updateDeadline(let updateRequest, let todoId):
            let endpoint = url.appendingPathComponent("/todo/\(todoId)/deadline")
            request = URLRequest(url: endpoint)
            request.httpMethod = "PATCH"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let accessToken = accessToken {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            request.httpBody = try JSONEncoder().encode(updateRequest)
            
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
            
        // yesterday
        case .getYesterdayList(let page, let size):
            var components = URLComponents(url: url.appendingPathComponent("/yesterdays"), resolvingAgainstBaseURL: false)
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
        case .updateTodoCompletion(let todoId):
            let endpoint = url.appendingPathComponent("/todo/\(todoId)/achieve")
            request = URLRequest(url: endpoint)
            request.httpMethod = "PATCH"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let accessToken = accessToken {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
        case .updateBookmark(let todoId):
            let endpoint = url.appendingPathComponent("/todo/\(todoId)/bookmark")
            request = URLRequest(url: endpoint)
            request.httpMethod = "PATCH"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let accessToken = accessToken {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
        case .dragAndDrop(let type, let todoIds):
            let endpoint = url.appendingPathComponent("/dragAndDrop")
            request = URLRequest(url: endpoint)
            request.httpMethod = "PATCH"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let accessToken = accessToken {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            request.httpBody = try JSONEncoder().encode(DragAndDropRequest(type: type, todoIds: todoIds))
            
        // mypage
        case .getUserInfo:
            let endpoint = url.appendingPathComponent("/user/mypage")
            request = URLRequest(url: endpoint)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let accessToken = accessToken {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
        case .getPolicy:
            let endpoint = url.appendingPathComponent("/policy")
            request = URLRequest(url: endpoint)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
    
        return request
    }
}
