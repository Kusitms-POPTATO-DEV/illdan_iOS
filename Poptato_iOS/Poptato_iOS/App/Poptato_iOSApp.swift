//
//  Poptato_iOSApp.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/21/24.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth
import FirebaseCore
import Firebase
import FirebaseMessaging
import FirebaseAnalytics
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Analytics.setAnalyticsCollectionEnabled(true)

        // APNs 등록
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
          print("Permission granted: \(granted)")
        }

        application.registerForRemoteNotifications()

        // FCM Messaging Delegate 설정
        Messaging.messaging().delegate = self

        return true
    }
    
    // APNs 토큰 등록
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // APNs 등록 실패 처리
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    
    // FCM 토큰 생성 시 호출
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM Token: \(fcmToken ?? "")")
        // 토큰 저장 또는 서버로 전송
    }

    // 앱이 포그라운드에 있을 때 푸시 알림 처리
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }

    // 사용자가 알림을 클릭했을 때 처리
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("User tapped notification: \(userInfo)")
        completionHandler()
    }
}

@main
struct Poptato_iOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        KakaoSDK.initSDK(appKey: Secrets.kakaoAppKey)
    }
    
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject private var splashViewModel = SplashViewModel()
    @State private var finishSplash = false
    @State private var isLogined = false
    @State private var isFirstLaunch = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if finishSplash {
                    MainView(isLogined: $isLogined)
                }
                else {
                    SplashView()
                        .onAppear(perform: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                Task{
                                    isLogined = await splashViewModel.checkLogin()
                                    finishSplash = true
                                    isFirstLaunch = false
                                }
                            }
                        })
                }
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active && !isFirstLaunch {
                    Task {
                        await NetworkManager.shared.refreshToken()
                    }
                }
            }
        }
    }
}
