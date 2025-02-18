//
//  CategoryRepositoryImpl.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/26/24.
//

final class CategoryRepositoryImpl: CategoryRepository {
    func getCategoryList(page: Int, size: Int, mobileType: String) async throws -> CategoryListResponse {
        try await NetworkManager.shared.request(type: CategoryListResponse.self, api: .getCategoryList(page: page, size: size, mobileType: mobileType))
    }
    
    func getEmojiList(mobileType: String) async throws -> EmojiResponse {
        try await NetworkManager.shared.request(type: EmojiResponse.self, api: .getEmojiList(mobileType: mobileType))
    }
    
    func createCategory(request: CreateCategoryRequest) async throws {
        try await NetworkManager.shared.request(api: .createCategory(category: request))
    }
    
    func deleteCategory(categoryId: Int) async throws {
        try await NetworkManager.shared.request(api: .deleteCategory(categoryId: categoryId))
    }
    
    func editCategory(categoryId: Int, category: CreateCategoryRequest) async throws {
        try await NetworkManager.shared.request(api: .editCategory(categoryId: categoryId, category: category))
    }
}
