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
    case getBacklogList(page: Int, size: Int, categoryId: Int)
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
    case updateTodoRepeat(todoId: Int)
    case getTodoDetail(todoId: Int)
    case updateCategory(todoId: Int, categoryId: CategoryIdModel)
    
    // mypage
    case getUserInfo
    case getPolicy
    
    // history
    case getHistory(date: String)
    case getMonthlyHistory(year: String, month: Int)
    
    // category
    case getCategoryList(page: Int, size: Int)
    case getEmojiList
    case createCategory(category: CreateCategoryRequest)
    case deleteCategory(categoryId: Int)
    case editCategory(categoryId: Int, category: CreateCategoryRequest)
    
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
        case .getBacklogList(let page, let size, let categoryId):
            var components = URLComponents(url: url.appendingPathComponent("/backlogs"), resolvingAgainstBaseURL: false)
            components?.queryItems = [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "size", value: "\(size)"),
                URLQueryItem(name: "category", value: "\(categoryId)")
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
            let endpoint = url.appendingPathComponent("todo/dragAndDrop")
            request = URLRequest(url: endpoint)
            request.httpMethod = "PATCH"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let accessToken = accessToken {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            request.httpBody = try JSONEncoder().encode(DragAndDropRequest(type: type, todoIds: todoIds))
        case .updateTodoRepeat(let todoId):
            let endpoint = url.appendingPathComponent("/todo/\(todoId)/repeat")
            request = URLRequest(url: endpoint)
            request.httpMethod = "PATCH"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let accessToken = accessToken {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
        case .getTodoDetail(let todoId):
            let endpoint = url.appendingPathComponent("/todo/\(todoId)")
            request = URLRequest(url: endpoint)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let accessToken = accessToken {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
        case .updateCategory(let todoId, let categoryId):
            let endpoint = url.appendingPathComponent("/todo/\(todoId)/category")
            request = URLRequest(url: endpoint)
            request.httpMethod = "PATCH"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let accessToken = accessToken {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            request.httpBody = try JSONEncoder().encode(categoryId)
            
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
            
        // history
        case .getHistory(let date):
            var components = URLComponents(url: url.appendingPathComponent("/histories"), resolvingAgainstBaseURL: false)
            components?.queryItems = [
                URLQueryItem(name: "date", value: "\(date)")
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
        case .getMonthlyHistory(let year, let month):
            var components = URLComponents(url: url.appendingPathComponent("/calendar"), resolvingAgainstBaseURL: false)
            components?.queryItems = [
                URLQueryItem(name: "year", value: "\(year)"),
                URLQueryItem(name: "month", value: "\(month)")
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
            
        // category
        case .getCategoryList(let page, let size):
            var components = URLComponents(url: url.appendingPathComponent("/category/list"), resolvingAgainstBaseURL: false)
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
        case .getEmojiList:
            let endpoint = url.appendingPathComponent("/emojis")
            request = URLRequest(url: endpoint)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let accessToken = accessToken {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
        case .createCategory(let category):
            let endpoint = url.appendingPathComponent("/category")
            request = URLRequest(url: endpoint)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let accessToken = accessToken {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            request.httpBody = try JSONEncoder().encode(category)
        case .deleteCategory(let categoryId):
            let endpoint = url.appendingPathComponent("/category/\(categoryId)")
            request = URLRequest(url: endpoint)
            request.httpMethod = "DELETE"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let accessToken = accessToken {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
        case .editCategory(let categoryId, let category):
            let endpoint = url.appendingPathComponent("/category/\(categoryId)")
            request = URLRequest(url: endpoint)
            request.httpMethod = "PUT"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let accessToken = accessToken {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
            request.httpBody = try JSONEncoder().encode(category)
        }
    
        return request
    }
}
