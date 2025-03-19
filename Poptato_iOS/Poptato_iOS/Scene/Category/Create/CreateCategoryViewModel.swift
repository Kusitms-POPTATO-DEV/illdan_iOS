//
//  CreateCategoryViewModel.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/27/24.
//

import SwiftUI

final class CreateCategoryViewModel: ObservableObject {
    private var categoryRepository: CategoryRepository
    @Published var emojiList: [String : [EmojiModel]] = [:]
    @Published var categoryId: Int = 0
    @Published var categoryInput: String = ""
    @Published var selectedEmoji: EmojiModel?
    
    init(
        categoryRepository: CategoryRepository = CategoryRepositoryImpl()
    ) {
        self.categoryRepository = categoryRepository
    }
    
    func getEmojiList() async {
        do {
            let response = try await categoryRepository.getEmojiList(mobileType: "IOS")
            
            await MainActor.run {
                emojiList = response.groupEmojis
            }
        } catch {
            print("Error getEmojiList: \(error)")
        }
    }
    
    func createCategory(name: String, emojiId: Int) async {
        do {
            AnalyticsManager.shared.logEvent(
                AnalyticsEvent.make_category,
                parameters: [
                    "emoji_id" : selectedEmoji?.id ?? -1
                ]
            )
            try await categoryRepository.createCategory(request: CreateCategoryRequest(name: name, emojiId: emojiId))
        } catch {
            print("Error createCategory: \(error)")
        }
    }
    
    func editCategory(name: String, emojiId: Int) async {
        do {
            try await categoryRepository.editCategory(categoryId: categoryId, category: CreateCategoryRequest(name: name, emojiId: emojiId))
        } catch {
            print("Error editCategory: \(error)")
        }
    }
}
