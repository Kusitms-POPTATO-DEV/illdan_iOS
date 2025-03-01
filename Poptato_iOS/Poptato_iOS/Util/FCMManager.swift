//
//  FCMManager.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 3/1/25.
//

import FirebaseMessaging
import Foundation

final class FCMManager {
    static let shared = FCMManager()
    private init() {}
    
    func getFCMToken() async throws -> String? {
        return try await withCheckedThrowingContinuation { continuation in
            Messaging.messaging().token { token, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: token)
                }
            }
        }
    }
}
