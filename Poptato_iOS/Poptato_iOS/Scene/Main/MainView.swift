//
//  MainView.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/23/24.
//

import SwiftUI
import KakaoSDKAuth

struct MainView: View {
    @Binding var isLogined: Bool
    @State private var selectedTab: Int = 0
    @State private var isLoading: Bool = true
    @State private var isBottomSheetVisible = false
    @State private var isDateBottomSheetVisible = false
    @State private var isCategoryBottomSheetVisible = false
    @State private var isTimePickerBottomSheetVisible = false
    @State private var isPolicyViewPresented = false
    @State private var isYesterdayViewPresented = false
    @State private var isMotivationViewPresented = false
    @State private var isCreateCategoryViewPresented = false
    @State private var isToastPresented = false
    @State private var toastMessage = ""
    @StateObject private var backlogViewModel = BacklogViewModel()
    @StateObject private var todayViewModel = TodayViewModel()
    
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
                            
                            if newValue == 0 && backlogViewModel.showSecondGuideBubble { backlogViewModel.showSecondGuideBubble = false }
                        }
                    )) {
                        TodayView(
                            goToBacklog: { self.selectedTab = 1 },
                            onItemSelcted: { item in
                                Task {
                                    await todayViewModel.getTodoDetail(item: item)
                                    withTransaction(Transaction(animation: .easeInOut)) {
                                        isBottomSheetVisible = true
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
                        .environmentObject(todayViewModel)
                        .tag(0)
                        
                        BacklogView(
                            onItemSelcted: { item in
                                Task {
                                    await backlogViewModel.getTodoDetail(item: item)
                                    withTransaction(Transaction(animation: .easeInOut)) {
                                        isBottomSheetVisible = true
                                    }
                                }
                            },
                            isYesterdayTodoViewPresented: $isYesterdayViewPresented,
                            isCreateCategoryViewPresented: $isCreateCategoryViewPresented
                        )
                        .tabItem {
                            Label("", image: selectedTab == 1 ? "ic_backlog_selected" : "ic_backlog_unselected")
                        }
                        .environmentObject(backlogViewModel)
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
                            isPolicyViewPresented: $isPolicyViewPresented
                        )
                        .tabItem {
                            Label("", image: selectedTab == 3 ? "ic_my_selected" : "ic_mypage")
                        }
                        .tag(3)
                    }
                    
                    if backlogViewModel.showSecondGuideBubble {
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
                            isCategoryCreated: $backlogViewModel.isCategoryCreated,
                            isCategoryEdited: $backlogViewModel.isCategoryEdited,
                            initialCategoryId: backlogViewModel.categoryList[backlogViewModel.selectedCategoryIndex].id,
                            initialCategoryName: backlogViewModel.categoryList[backlogViewModel.selectedCategoryIndex].name,
                            initialSelectedEmoji: EmojiModel(
                                emojiId: backlogViewModel.categoryList[backlogViewModel.selectedCategoryIndex].emojiId,
                                imageUrl: backlogViewModel.categoryList[backlogViewModel.selectedCategoryIndex].imageUrl
                            ),
                            isCategoryEditMode: backlogViewModel.isCategoryEditMode
                        )
                    }
                } else {
                    LoginView(
                        onSuccessLogin: { isNew in
                            backlogViewModel.isNewUser = isNew
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
                                backlogViewModel.updateSelectedItem(item: nil)
                                todayViewModel.selectedTodoItem = nil
                            }
                            isDateBottomSheetVisible = false
                            isCategoryBottomSheetVisible = false
                        }
                }
                
                if isBottomSheetVisible, let todoItem = backlogViewModel.selectedTodoItem {
                    BottomSheetView(
                        isVisible: $isBottomSheetVisible,
                        todoItem: $backlogViewModel.selectedTodoItem,
                        showDateBottomSheet: $isDateBottomSheetVisible,
                        showCategoryBottomSheet: $isCategoryBottomSheetVisible,
                        showTimePickerBottomSheet: $isTimePickerBottomSheetVisible,
                        deleteTodo: {
                            Task {
                                await backlogViewModel.deleteBacklog(todoId: todoItem.todoId)
                                showToast(message: "할 일이 삭제되었어요.")
                            }
                        },
                        editTodo: {
                            backlogViewModel.activeItemId = todoItem.todoId
                        },
                        updateBookmark: {
                            Task {
                                await backlogViewModel.updateBookmark(todoId: todoItem.todoId)
                            }
                        },
                        updateDeadline: { deadline in
                            Task {
                                await backlogViewModel.updateDeadline(
                                    todoId: todoItem.todoId,
                                    deadline: deadline
                                )
                            }
                        },
                        updateTodoRepeat: {
                            Task {
                                await backlogViewModel.updateTodoRepeat(todoId: todoItem.todoId)
                            }
                        },
                        updateCategory: { id in
                            Task {
                                await backlogViewModel.updateCategory(categoryId: id, todoId: backlogViewModel.selectedTodoItem!.todoId)
                            }
                        },
                        categoryList: backlogViewModel.categoryList
                    )
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
                }
                
                if isBottomSheetVisible, let todoItem = todayViewModel.selectedTodoItem {
                    BottomSheetView(
                        isVisible: $isBottomSheetVisible,
                        todoItem: $todayViewModel.selectedTodoItem,
                        showDateBottomSheet: $isDateBottomSheetVisible,
                        showCategoryBottomSheet: $isCategoryBottomSheetVisible,
                        showTimePickerBottomSheet: $isTimePickerBottomSheetVisible,
                        deleteTodo: {
                            Task {
                                await todayViewModel.deleteTodo(todoId: todoItem.todoId)
                                showToast(message: "할 일이 삭제되었어요.")
                            }
                        },
                        editTodo: {
                            todayViewModel.activeItemId = todoItem.todoId
                        },
                        updateBookmark: {
                            Task {
                                await todayViewModel.updateBookmark(todoId: todoItem.todoId)
                            }
                        },
                        updateDeadline: { deadline in
                            Task {
                                await todayViewModel.updateDeadline(
                                    todoId: todoItem.todoId,
                                    deadline: deadline
                                )
                            }
                        },
                        updateTodoRepeat: {
                            Task {
                                await todayViewModel.updateTodoRepeat(todoId: todoItem.todoId)
                            }
                        },
                        updateCategory: { id in
                            Task {
                                await todayViewModel.updateCategory(categoryId: id, todoId: todayViewModel.selectedTodoItem!.todoId)
                            }
                        },
                        categoryList: backlogViewModel.categoryList
                    )
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
                }
            }
        }
        .fullScreenCover(isPresented: $isYesterdayViewPresented, onDismiss: {
            selectedTab = todayViewModel.todayList.isEmpty ? 1 : 0
            isLoading = false
        }) {
            YesterdayTodoView(
                isYesterdayTodoViewPresented: $isYesterdayViewPresented,
                isMotivationViewPresented: $isMotivationViewPresented
            )
        }
        .toast(isPresented: $isToastPresented, message: toastMessage)
        .onAppear {
            Task {
                await todayViewModel.getTodayList()
                
                if backlogViewModel.isExistYesterdayTodo {
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
    }
    
    private func showToast(message: String) {
        toastMessage = message
        isToastPresented = true
    }
}
