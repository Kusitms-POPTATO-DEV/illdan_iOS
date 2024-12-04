//
//  MainView.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/23/24.
//

import SwiftUI

struct MainView: View {
    @Binding var isLogined: Bool
    @State private var selectedTab: Int = 1
    @State private var isBottomSheetVisible = false
    @State private var isPolicyViewPresented = false
    @State private var isYesterdayViewPresented = false
    @State private var isMotivationViewPresented = false
    @State private var isCreateCategoryViewPresented = false
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
            if isLogined {
                TabView(selection: $selectedTab) {
                    TodayView(
                        goToBacklog: { selectedTab = 1 }
                    )
                    .tabItem {
                        Label("오늘", image: selectedTab == 0 ? "ic_today_selected" : "ic_today_unselected")
                            .font(PoptatoTypo.xsMedium)
                    }
                    .environmentObject(todayViewModel)
                    .tag(0)
                    
                    BacklogView(
                        onItemSelcted: { item in
                            withTransaction(Transaction(animation: .easeInOut)) {
                                backlogViewModel.updateSelectedItem(item: item)
                                isBottomSheetVisible = true
                            }
                        },
                        isYesterdayTodoViewPresented: $isYesterdayViewPresented,
                        isCreateCategoryViewPresented: $isCreateCategoryViewPresented
                    )
                    .tabItem {
                        Label("할 일", image: selectedTab == 1 ? "ic_backlog_selected" : "ic_backlog_unselected")
                            .font(PoptatoTypo.xsMedium)
                    }
                    .environmentObject(backlogViewModel)
                    .tag(1)
                    
                    HistoryView(
                        
                    )
                    .tabItem {
                        Label("기록", image: selectedTab == 2 ? "ic_clock_selected" : "ic_clock_unselected")
                    }
                    .tag(2)
                    
                    
                    MyPageView(
                        goToKaKaoLogin: { isLogined = false },
                        isPolicyViewPresented: $isPolicyViewPresented
                    )
                    .tabItem {
                        Label("마이", image: "ic_mypage")
                            .font(PoptatoTypo.xsMedium)
                    }
                    .tag(3)
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
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                isMotivationViewPresented = false
                            }
                        }
                }
                
                if isCreateCategoryViewPresented {
                    CreateCategoryView(
                        isPresented: $isCreateCategoryViewPresented
                    )
                }
            } else {
                KaKaoLoginView(
                    onSuccessLogin: { isLogined = true }
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
                        }
                    }
            }
            
            if isBottomSheetVisible, let todoItem = backlogViewModel.selectedTodoItem {
                BottomSheetView(
                    isVisible: $isBottomSheetVisible,
                    todoItem: $backlogViewModel.selectedTodoItem,
                    deleteTodo: {
                        Task {
                            await backlogViewModel.deleteBacklog(todoId: todoItem.todoId)
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
                    }
                )
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
        }
    }
}
