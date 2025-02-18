//
//  CategoryRepository.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/26/24.
//

protocol CategoryRepository {
    func getCategoryList(page: Int, size: Int, mobileType: String) async throws -> CategoryListResponse
    func getEmojiList(mobileType: String) async throws -> EmojiResponse
    func createCategory(request: CreateCategoryRequest) async throws -> Void
    func deleteCategory(categoryId: Int) async throws -> Void
    func editCategory(categoryId: Int, category: CreateCategoryRequest) async throws -> Void
}
