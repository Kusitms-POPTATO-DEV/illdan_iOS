//
//  MainViewModel.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 5/24/25.
//

import SwiftUI

final class TodoViewModel: ObservableObject {
    private let todoRepository: TodoRepository = TodoRepositoryImpl()
    private let categoryRepository: CategoryRepository = CategoryRepositoryImpl()
    
    @Published var selectedTodoItem: TodoItemModel? = .placeholder
    @Published var categoryList: Array<CategoryModel> = []
    
    func getTodoDetail(item: TodoItemModel) async {
        do {
            let response = try await todoRepository.getTodoDetail(todoId: item.todoId)
            let categoryId = categoryList.first { category in
                category.name == response.categoryName && category.imageUrl == response.emojiImageUrl
            }?.id
            
            await MainActor.run {
                let newItem = TodoItemModel(
                    todoId: item.todoId,
                    content: item.content,
                    isBookmark: item.isBookmark,
                    isRepeat: item.isRepeat,
                    dDay: item.dDay,
                    deadline: item.deadline,
                    categoryId: categoryId,
                    categoryName: response.categoryName,
                    imageUrl: response.emojiImageUrl
                )
                updateSelectedItem(item: newItem)
            }
        } catch {
            print("Error getTodoDetail: \(error)")
        }
    }
    
    func updateSelectedItem(item: TodoItemModel?) {
        selectedTodoItem = item
    }
}
