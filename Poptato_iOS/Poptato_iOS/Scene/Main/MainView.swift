//
//  MainView.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/23/24.
//

import SwiftUI

struct MainView: View {
    @State private var selectedTab: Int = 1
    @State private var isLogined = false
    @State private var isBottomSheetVisible = false
    @State private var selectedTodoItem: TodoItemModel? = nil
    @StateObject private var backlogViewModel = BacklogViewModel()
    
    init() {
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
                    .tag(0)
                    BacklogView(
                        onItemSelcted: { item in
                            selectedTodoItem = item
                        },
                        showBottomSheet: {
                            isBottomSheetVisible = true
                        }
                    )
                    .tabItem {
                        Label("할 일", image: selectedTab == 1 ? "ic_backlog_selected" : "ic_backlog_unselected")
                            .font(PoptatoTypo.xsMedium)
                    }
                    .environmentObject(backlogViewModel)
                    .tag(1)
                }
            } else {
                KaKaoLoginView(
                    onSuccessLogin: { isLogined = true }
                )
            }
            
            if isBottomSheetVisible, let todoItem = selectedTodoItem {
                BottomSheetView(
                    isVisible: $isBottomSheetVisible,
                    todoItem: todoItem,
                    deleteTodo: {
                        Task {
                            await backlogViewModel.deleteBacklog(todoId: todoItem.todoId)
                        }
                    },
                    editTodo: {
                        backlogViewModel.activeItemId = todoItem.todoId
                    }
                )
            }
        }
    }
}

#Preview {
    MainView()
}
