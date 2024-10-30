//
//  TodayViewModel.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/27/24.
//

import SwiftUI
import Foundation

final class TodayViewModel: ObservableObject {
    @Published var todayList: Array<TodayItemModel> = []
    @Published var currentDate: String = ""
    private var snapshotList: [TodayItemModel] = []
    private let todayRepository: TodayRepository
    private let todoRepository: TodoRepository
    
    init(
        todayRepository: TodayRepository = TodayRepositoryImpl(),
        todoRepository: TodoRepository = TodoRepositoryImpl()
    ) {
        self.todayRepository = todayRepository
        self.todoRepository = todoRepository
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        currentDate = formatter.string(from: Date())
    }
    
    func getTodayList() async {
        do {
            let response = try await todayRepository.getTodayList(page: 0, size: 50)
            DispatchQueue.main.async {
                self.todayList = response.todays.map { item in
                    TodayItemModel(
                        todoId: item.todoId,
                        content: item.content,
                        todayStatus: item.todayStatus,
                        bookmark: item.bookmark,
                        dday: item.dday,
                        deadline: item.deadline
                    )
                }
                self.snapshotList = self.todayList
            }
        } catch {
            DispatchQueue.main.async {
                print("Error getTodayList \(error)")
            }
        }
    }
    
    func swipeToday(todoId: Int) async {
        await MainActor.run {
            self.snapshotList = self.todayList
        }
        
        do {
            try await todoRepository.swipeTodo(request: TodoIdModel(todoId: todoId))
            await MainActor.run {
                self.snapshotList = self.todayList
            }
        } catch {
            await MainActor.run {
                print("Error swipe today: \(error)")
                self.todayList = self.snapshotList
            }
        }
    }
    
    func updateTodoCompletion(todoId: Int) async {
        let previousSnapshot = todayList
        
        do {
            try await todoRepository.updateTodoCompletion(todoId: todoId)
            snapshotList = todayList
        } catch {
            DispatchQueue.main.async {
                print("Error update todocompletion: \(error)")
                self.todayList = previousSnapshot
            }
        }
    }
}
