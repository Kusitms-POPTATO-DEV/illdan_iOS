//
//  AnalyticsManager.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 3/19/25.
//

import FirebaseAnalytics

protocol AnalyticsService {
    func logEvent(name: String, parameters: [String: Any]?)
}

final class FirebaseAnalyticsService: AnalyticsService {
    func logEvent(name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
    }
}

final class AnalyticsManager {
    static let shared = AnalyticsManager(service: FirebaseAnalyticsService())
    private let service: AnalyticsService
    
    private init(service: AnalyticsService) {
        self.service = service
    }
    
    func logEvent(name: String, parameters: [String: Any]? = nil) {
        service.logEvent(name: name, parameters: parameters)
    }
}

enum AnalyticsEvent: String {
    case apple_login = "login_apple"
    case kakao_login = "login_kakao"
    case make_task = "make_task"
    case add_today = "add_today"
    case make_category = "make_category"
    case view_category = "view_category"
    case delete_category = "delete_category"
    case complete_task = "complete_task"
    case complete_all = "complete_all"
    case drag_tasks = "drag_tasks"
    case drag_today = "drag_today"
    case back_tasks = "back_tasks"
    case get_backlog = "get_backlog"
    case get_today = "get_today"
    case get_calendar = "get_calendar"
    case today_bottom_sheet = "today_bottom_sheet"
    case check_date = "check_date"
    case check_month = "check_month"
    case edit_task = "edit_task"
    case delete_task = "delete_task"
    case set_dday = "set_dday"
    case set_repeat = "set_repeat"
    case set_category = "set_category"
    case set_important = "set_important"
    case delete_account = "delete_account"
    case set_time = "set_time"
    case notice = "notice"
    case terms = "terms"
    case faq = "faq"
}

extension AnalyticsManager {
    func logEvent(_ event: AnalyticsEvent, parameters: [String: Any]? = nil) {
        logEvent(name: event.rawValue, parameters: parameters)
    }
}
