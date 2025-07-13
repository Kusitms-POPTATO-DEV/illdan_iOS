//
//  MainView.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/23/24.
//

import SwiftUI
import KakaoSDKAuth

struct MainView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Binding var isLogined: Bool
    @State private var selectedTab: Int = 0
    @State private var isLoading: Bool = true
    @State private var isBottomSheetVisible = false
    @State private var isDateBottomSheetVisible = false
    @State private var isCategoryBottomSheetVisible = false
    @State private var isTimePickerBottomSheetVisible = false
    @State private var isRoutineBottomSheetVisible = false
    @State private var isPolicyViewPresented = false
    @State private var isYesterdayViewPresented = false
    @State private var isUserCommentViewPresented = false
    @State private var isMotivationViewPresented = false
    @State private var isCreateCategoryViewPresented = false
    @State private var isToastPresented = false
    @State private var toastMessage = ""
    @StateObject private var todoViewModel = TodoViewModel()
    @StateObject private var myPageViewModel = MyPageViewModel()
    
    init(isLogined: Binding<Bool>) {
        self._isLogined = isLogined
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.gray100)
    
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.gray90)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Color.gray80)]
        
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.primary60)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color.primary60)]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        ZStack {
            if isLoading {
                Color.gray100.edgesIgnoringSafeArea(.all)  
            } else {
                if isLogined {
                    TabView(selection: Binding(
                        get: { selectedTab },
                        set: { newValue in
                            self.selectedTab = newValue
                            
                            if newValue == 0 && todoViewModel.showSecondGuideBubble { todoViewModel.showSecondGuideBubble = false }
                        }
                    )) {
                        TodayView(
                            goToBacklog: { self.selectedTab = 1 },
                            onItemSelcted: { item in
                                Task {
                                    await todoViewModel.getTodoDetail(item: item, isToday: true)
                                    await MainActor.run {
                                        withTransaction(Transaction(animation: .easeInOut)) {
                                            isBottomSheetVisible = true
                                        }
                                    }
                                }
                            },
                            showToast: { message in
                                showToast(message: message)
                            }
                        )
                        .tabItem {
                            Label("", image: selectedTab == 0 ? "ic_today_selected" : "ic_today_unselected")
                        }
                        .environmentObject(todoViewModel)
                        .tag(0)
                        
                        BacklogView(
                            onItemSelcted: { item in
                                Task {
                                    await todoViewModel.getTodoDetail(item: item, isToday: false)
                                    await MainActor.run {
                                        withTransaction(Transaction(animation: .easeInOut)) {
                                            isBottomSheetVisible = true
                                        }
                                    }
                                }
                            },
                            isCreateCategoryViewPresented: $isCreateCategoryViewPresented
                        )
                        .tabItem {
                            Label("", image: selectedTab == 1 ? "ic_backlog_selected" : "ic_backlog_unselected")
                        }
                        .environmentObject(todoViewModel)
                        .tag(1)
                        
                        HistoryView()
                            .tabItem {
                                Label("", image: selectedTab == 2 ? "ic_calendar_nav_selected" : "ic_calendar_nav_unselected")
                            }
                            .tag(2)
                        
                        MyPageView(
                            goToKaKaoLogin: {
                                isLogined = false
                                selectedTab = 0
                            },
                            goToUserCommentView: { isUserCommentViewPresented = true },
                            isPolicyViewPresented: $isPolicyViewPresented
                        )
                        .environmentObject(myPageViewModel)
                        .tabItem {
                            Label("", image: selectedTab == 3 ? "ic_my_selected" : "ic_mypage")
                        }
                        .tag(3)
                    }
                    
                    if todoViewModel.showSecondGuideBubble {
                        VStack {
                            Spacer()
                            HStack {
                                Image("ic_guide_bubble_2")
                                    .padding(.leading, 20)
                                    .padding(.bottom, 50)
                                Spacer()
                            }
                        }
                    }
                    
                    if isPolicyViewPresented {
                        PolicyView(isPolicyViewPresented: $isPolicyViewPresented)
                    }
                    
                    if isYesterdayViewPresented {
                        YesterdayTodoView(
                            isYesterdayTodoViewPresented: $isYesterdayViewPresented,
                            isMotivationViewPresented: $isMotivationViewPresented
                        )
                    }
                    
                    if isMotivationViewPresented {
                        MotivationView()
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                    isMotivationViewPresented = false
                                }
                            }
                    }
                    
                    if isCreateCategoryViewPresented {
                        CreateCategoryView(
                            isPresented: $isCreateCategoryViewPresented,
                            isCategoryCreated: $todoViewModel.isCategoryCreated,
                            isCategoryEdited: $todoViewModel.isCategoryEdited,
                            initialCategoryId: todoViewModel.categoryList[todoViewModel.selectedCategoryIndex].id,
                            initialCategoryName: todoViewModel.categoryList[todoViewModel.selectedCategoryIndex].name,
                            initialSelectedEmoji: EmojiModel(
                                emojiId: todoViewModel.categoryList[todoViewModel.selectedCategoryIndex].emojiId,
                                imageUrl: todoViewModel.categoryList[todoViewModel.selectedCategoryIndex].imageUrl
                            ),
                            isCategoryEditMode: todoViewModel.isCategoryEditMode
                        )
                    }
                } else {
                    LoginView(
                        onSuccessLogin: { isNew in
                            todoViewModel.isNewUser = isNew
                            isLogined = true
                        }
                    )
                }
                
                if isBottomSheetVisible {
                    Color.black.opacity(0.6)
                        .edgesIgnoringSafeArea(.all)
                        .transition(.opacity)
                        .animation(nil, value: isBottomSheetVisible)
                        .onTapGesture {
                            withAnimation {
                                isBottomSheetVisible = false
                                isDateBottomSheetVisible = false
                                isCategoryBottomSheetVisible = false
                                isRoutineBottomSheetVisible = false
                                todoViewModel.updateSelectedTodo(item: nil)
                            }
                        }
                }
                
                if isBottomSheetVisible, let todoItem = todoViewModel.selectedTodoItem {
                    BottomSheetView(
                        isVisible: $isBottomSheetVisible,
                        todoItem: $todoViewModel.selectedTodoItem,
                        showDateBottomSheet: $isDateBottomSheetVisible,
                        showCategoryBottomSheet: $isCategoryBottomSheetVisible,
                        showTimePickerBottomSheet: $isTimePickerBottomSheetVisible,
                        showRoutineBottomSheet: $isRoutineBottomSheetVisible,
                        deleteTodo: {
                            Task {
                                await todoViewModel.deleteTodo(todoId: todoItem.todoId)
                                showToast(message: "할 일이 삭제되었어요.")
                            }
                        },
                        editTodo: {
                            todoViewModel.activeItemId = todoItem.todoId
                        },
                        updateBookmark: {
                            Task {
                                await todoViewModel.updateBookmark(todoId: todoItem.todoId)
                            }
                        },
                        updateDeadline: { deadline in
                            Task {
                                await todoViewModel.updateDeadline(
                                    todoId: todoItem.todoId,
                                    deadline: deadline
                                )
                            }
                        },
                        updateTodoRepeat: { newValue in
                            Task {
                                if newValue { await todoViewModel.setTodoRepeat(todoId: todoItem.todoId) }
                                else { await todoViewModel.deleteTodoRepeat(todoId: todoItem.todoId) }
                            }
                        },
                        updateCategory: { id in
                            Task {
                                await todoViewModel.updateCategory(categoryId: id, todoId: todoViewModel.selectedTodoItem!.todoId)
                            }
                        },
                        updateTodoTime: { info in
                            Task {
                                await todoViewModel.updateTodoTime(timeInfo: info)
                            }
                        },
                        updateTodoRoutine: { newValue in
                            Task {
                                if let days = newValue {
                                    await todoViewModel.setTodoRoutine(todoId: todoItem.todoId, days: days)
                                } else {
                                    await todoViewModel.deleteTodoRoutine(todoId: todoItem.todoId)
                                }
                            }
                        },
                        categoryList: todoViewModel.categoryList
                    )
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
                }
            }
        }
        .fullScreenCover(isPresented: $todoViewModel.isExistYesterdayTodo, onDismiss: {
            selectedTab = 0
            isLoading = false
        }) {
            YesterdayTodoView(
                isYesterdayTodoViewPresented: $todoViewModel.isExistYesterdayTodo,
                isMotivationViewPresented: $isMotivationViewPresented
            )
        }
        .fullScreenCover(isPresented: $isUserCommentViewPresented) {
            UserCommentView(
                onClickBtnBack: { isUserCommentViewPresented = false }
            )
            .environmentObject(myPageViewModel)
        }
        .toast(isPresented: $isToastPresented, message: toastMessage)
        .toast(isPresented: $myPageViewModel.showSuccessToast, message: "더 나은 서비스로 보답할게요")
        .onAppear {
            Task {
                if todoViewModel.isExistYesterdayTodo {
                    isYesterdayViewPresented = true
                } else {
                    isLoading = false
                }
            }
        }
        .onOpenURL { url in
            print("Received URL: \(url)")
            if AuthApi.isKakaoTalkLoginUrl(url) {
                _ = AuthController.handleOpenUrl(url: url, options: [:])
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                Task {
                    await todoViewModel.getYesterdayList(page: 0, size: 1)
                }
            }
        }
        .onChange(of: selectedTab) { newValue in
            if newValue == 0 { AnalyticsManager.shared.logEvent(AnalyticsEvent.get_today) }
            else if newValue == 1 { AnalyticsManager.shared.logEvent(AnalyticsEvent.get_backlog) }
            else if newValue == 2 { AnalyticsManager.shared.logEvent(AnalyticsEvent.get_calendar) }
        }
        .onChange(of: todoViewModel.isExistYesterdayTodo) { newValue in
            if !newValue {
                todoViewModel.currentDate = TimeFormatter.getCurrentMonthDay()
                // 어제 한 일 페이지가 종료된 이후에 새로운 리스트 조회
                Task {
                    await todoViewModel.getTodayList()
                    await todoViewModel.getBacklogList()
                }
            }
        }
    }
    
    private func showToast(message: String) {
        toastMessage = message
        isToastPresented = true
    }
}
