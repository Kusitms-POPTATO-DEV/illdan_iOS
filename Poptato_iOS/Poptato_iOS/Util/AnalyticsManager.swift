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
    case login = "login"
    case logout = "logout"
    case purchase = "purchase"
}

extension AnalyticsManager {
    func logEvent(_ event: AnalyticsEvent, parameters: [String: Any]? = nil) {
        logEvent(name: event.rawValue, parameters: parameters)
    }
}
