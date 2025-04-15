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
    case kakaoLogin(loginRequest: LoginRequest)
    case reissueToken(reissueRequest: ReissueTokenRequest)
    case logout(logoutRequest: LogoutRequest)
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
    case updateYesterdayCompletion(todoIdsRequest: TodoIdsRequest)
    
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
    case getCategoryList(page: Int, size: Int, mobileType: String)
    case getEmojiList(mobileType: String)
    case createCategory(category: CreateCategoryRequest)
    case deleteCategory(categoryId: Int)
    case editCategory(categoryId: Int, category: CreateCategoryRequest)
    case categoryDragAndDrop(categoryIds: [Int])
    
    var accessToken: String? {
        KeychainManager.shared.readToken(for: "accessToken")
    }
    var refreshToken: String? {
        KeychainManager.shared.readToken(for: "refreshToken")
    }
    var headers: HTTPHeaders {
        var headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "X-Mobile-Type": "IOS",
            "X-App-Version": "1.0"
        ]
        if let token = accessToken {
            headers.add(name: "Authorization", value: "Bearer \(token)")
        }
        return headers
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
            request.headers = headers
            request.httpBody = try JSONEncoder().encode(loginRequest)
        case .reissueToken(let reissueRequest):
            let endPoint = url.appendingPathComponent("/auth/refresh")
            request = URLRequest(url: endPoint)
            request.httpMethod = "POST"
            request.headers = headers
            request.httpBody = try JSONEncoder().encode(reissueRequest)
        case .logout(let logoutRequest):
            let endpoint = url.appendingPathComponent("/auth/logout")
            request = URLRequest(url: endpoint)
            request.httpMethod = "POST"
            request.headers = headers
            request.httpBody = try JSONEncoder().encode(logoutRequest)
        case .deleteAccount:
            let endpoint = url.appendingPathComponent("/user/delete")
            request = URLRequest(url: endpoint)
            request.httpMethod = "POST"
            request.headers = headers
            request.httpBody = try JSONEncoder().encode(DeleteAccountRequest(reasons: nil, userInputReason: nil))
            
        // backlog
        case .createBacklog(let createBacklogRequest):
            let endpoint = url.appendingPathComponent("/backlog")
            request = URLRequest(url: endpoint)
            request.httpMethod = "POST"
            request.headers = headers
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
            request.headers = headers
        case .deleteBacklog(let todoId):
            let endpoint = url.appendingPathComponent("/todo/\(todoId)")
            request = URLRequest(url: endpoint)
            request.httpMethod = "DELETE"
            request.headers = headers
        case .editBacklog(let todoId, let content):
            let endpoint = url.appendingPathComponent("/todo/\(todoId)/content")
            request = URLRequest(url: endpoint)
            request.httpMethod = "PATCH"
            request.headers = headers
            request.httpBody = try JSONEncoder().encode(TodoContentModel(content: content))
        case .updateDeadline(let updateRequest, let todoId):
            let endpoint = url.appendingPathComponent("/todo/\(todoId)/deadline")
            request = URLRequest(url: endpoint)
            request.httpMethod = "PATCH"
            request.headers = headers
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
            request.headers = headers
            
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
            request.headers = headers
        case .updateYesterdayCompletion(let todoIdsRequest):
            let endpoint = url.appendingPathComponent("/todo/check/yesterdays")
            request = URLRequest(url: endpoint)
            request.httpMethod = "POST"
            request.headers = headers
            request.httpBody = try JSONEncoder().encode(todoIdsRequest)
            
        // todo
        case .swipeTodo(let swipeRequest):
            let endpoint = url.appendingPathComponent("/swipe")
            request = URLRequest(url: endpoint)
            request.httpMethod = "PATCH"
            request.headers = headers
            request.httpBody = try JSONEncoder().encode(swipeRequest)
        case .updateTodoCompletion(let todoId):
            let endpoint = url.appendingPathComponent("/todo/\(todoId)/achieve")
            request = URLRequest(url: endpoint)
            request.httpMethod = "PATCH"
            request.headers = headers
        case .updateBookmark(let todoId):
            let endpoint = url.appendingPathComponent("/todo/\(todoId)/bookmark")
            request = URLRequest(url: endpoint)
            request.httpMethod = "PATCH"
            request.headers = headers
        case .dragAndDrop(let type, let todoIds):
            let endpoint = url.appendingPathComponent("todo/dragAndDrop")
            request = URLRequest(url: endpoint)
            request.httpMethod = "PATCH"
            request.headers = headers
            request.httpBody = try JSONEncoder().encode(DragAndDropRequest(type: type, todoIds: todoIds))
        case .updateTodoRepeat(let todoId):
            let endpoint = url.appendingPathComponent("/todo/\(todoId)/repeat")
            request = URLRequest(url: endpoint)
            request.httpMethod = "PATCH"
            request.headers = headers
        case .getTodoDetail(let todoId):
            var components = URLComponents(url: url.appendingPathComponent("/todo/\(todoId)"), resolvingAgainstBaseURL: false)
            components?.queryItems = [URLQueryItem(name: "mobileType", value: "IOS")]
            guard let endpoint = components?.url else {
                throw URLError(.badURL)
            }
            request = URLRequest(url: endpoint)
            request.httpMethod = "GET"
            request.headers = headers
        case .updateCategory(let todoId, let categoryId):
            let endpoint = url.appendingPathComponent("/todo/\(todoId)/category")
            request = URLRequest(url: endpoint)
            request.httpMethod = "PATCH"
            request.headers = headers
            request.httpBody = try JSONEncoder().encode(categoryId)
            
        // mypage
        case .getUserInfo:
            let endpoint = url.appendingPathComponent("/user/mypage")
            request = URLRequest(url: endpoint)
            request.httpMethod = "GET"
            request.headers = headers
        case .getPolicy:
            let endpoint = url.appendingPathComponent("/policy")
            request = URLRequest(url: endpoint)
            request.httpMethod = "GET"
            request.headers = headers
            
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
            request.headers = headers
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
            request.headers = headers
            
        // category
        case .getCategoryList(let page, let size, let mobileType):
            var components = URLComponents(url: url.appendingPathComponent("/category/list"), resolvingAgainstBaseURL: false)
            components?.queryItems = [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "size", value: "\(size)"),
                URLQueryItem(name: "mobileType", value: "\(mobileType)")
            ]
            guard let endpoint = components?.url else {
                throw URLError(.badURL)
            }
            request = URLRequest(url: endpoint)
            request.httpMethod = "GET"
            request.headers = headers
        case .getEmojiList(let mobileType):
            var components = URLComponents(url: url.appendingPathComponent("/emojis"), resolvingAgainstBaseURL: false)
            components?.queryItems = [
                URLQueryItem(name: "mobileType", value: "\(mobileType)")
            ]
            guard let endpoint = components?.url else {
                throw URLError(.badURL)
            }
            request = URLRequest(url: endpoint)
            request.httpMethod = "GET"
            request.headers = headers
        case .createCategory(let category):
            let endpoint = url.appendingPathComponent("/category")
            request = URLRequest(url: endpoint)
            request.httpMethod = "POST"
            request.headers = headers
            request.httpBody = try JSONEncoder().encode(category)
        case .deleteCategory(let categoryId):
            let endpoint = url.appendingPathComponent("/category/\(categoryId)")
            request = URLRequest(url: endpoint)
            request.httpMethod = "DELETE"
            request.headers = headers
        case .editCategory(let categoryId, let category):
            let endpoint = url.appendingPathComponent("/category/\(categoryId)")
            request = URLRequest(url: endpoint)
            request.httpMethod = "PUT"
            request.headers = headers
            request.httpBody = try JSONEncoder().encode(category)
        case .categoryDragAndDrop(let categoryIds):
            let endpoint = url.appendingPathComponent("/category/dragAndDrop")
            request = URLRequest(url: endpoint)
            request.httpMethod = "PATCH"
            request.headers = headers
            request.httpBody = try JSONEncoder().encode(CategoryDragDropRequest(categoryIds: categoryIds))
        }
    
        return request
    }
}
