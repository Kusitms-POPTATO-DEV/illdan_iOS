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
    
    // MARK: - 생성자
    
    init() {
        Task {
            await getCategoryList(page: 0, size: 100)
        }
    }
    
    // MARK: - 할 일 관련 메서드
    
    /// 역할: 특정 할 일의 상세 조회를 실행
    /// 상황: 오늘, 할 일 페이지에서 점 세개를 클릭하는 경우 호출
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
    
    /// 역할: 바텀시트에서 조작될 할 일 상태 변수를 업데이트
    /// 상황: getTodoDetail 메서드에서 함께 실행
    func updateSelectedItem(item: TodoItemModel?) {
        selectedTodoItem = item
    }
    
    // MARK: - 카테고리 관련 메서드
    
    /// 역할: 카테고리 리스트를 조회
    /// 상황: 1. TodoViewModel이 생성되는 경우, 2. 카테고리의 생성, 삭제, 수정, 순서 변경 이벤트가 발생한 경우
    func getCategoryList(page: Int, size: Int) async {
        do {
            let response = try await categoryRepository.getCategoryList(page: page, size: size, mobileType: "IOS")
            await MainActor.run {
                categoryList = response.categories
            }
        } catch {
            print("Error getCategoryList: \(error)")
        }
    }
}
