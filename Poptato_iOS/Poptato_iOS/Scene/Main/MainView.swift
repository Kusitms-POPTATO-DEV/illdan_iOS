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
                        }
                    )
                    .tabItem {
                        Label("할 일", image: selectedTab == 1 ? "ic_backlog_selected" : "ic_backlog_unselected")
                            .font(PoptatoTypo.xsMedium)
                    }
                    .environmentObject(backlogViewModel)
                    .tag(1)
                    
                    MyPageView(isPolicyViewPresented: $isPolicyViewPresented)
                        .tabItem {
                            Label("마이", image: "ic_mypage")
                                .font(PoptatoTypo.xsMedium)
                        }
                        .tag(2)
                }
                
                if isPolicyViewPresented {
                    PolicyView(isPolicyViewPresented: $isPolicyViewPresented)
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
                    }
                )
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
        }
    }
}
