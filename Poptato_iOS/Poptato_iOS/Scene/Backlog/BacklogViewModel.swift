//
//  BacklogViewModel.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/23/24.
//

import SwiftUI
import Combine

class BacklogViewModel: ObservableObject {
    private let backlogRepository: BacklogRepository
    @Published var backlogList: Array<TodoItemModel> = []
    
    init(backlogRepository: BacklogRepository = BacklogRepositoryImpl()) {
        self.backlogRepository = backlogRepository
    }
    
    func createBacklog(_ item: String) async {
        do {
            let response = try await backlogRepository.createBacklog(request: CreateBacklogRequest(content: item))
            DispatchQueue.main.async {
                self.backlogList.insert(
                    TodoItemModel(todoId: response.todoId, content: item, isBookmark: false, dDay: nil, deadline: nil),
                    at: 0
                )
            }
        } catch {
            DispatchQueue.main.async {
                print("Login error: \(error)")
            }
        }
    }
}
