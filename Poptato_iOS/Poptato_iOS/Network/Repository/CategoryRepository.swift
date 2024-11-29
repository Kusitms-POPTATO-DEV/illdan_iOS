//
//  CategoryRepository.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/26/24.
//

protocol CategoryRepository {
    func getCategoryList(page: Int, size: Int) async throws -> CategoryListResponse
    func getEmojiList() async throws -> EmojiResponse
    func createCategory(request: CreateCategoryRequest) async throws -> Void
}
