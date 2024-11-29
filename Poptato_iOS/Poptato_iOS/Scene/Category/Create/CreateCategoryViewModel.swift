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
    @Published var categoryInput: String = ""
    @Published var selectedEmoji: EmojiModel?
    
    init(
        categoryRepository: CategoryRepository = CategoryRepositoryImpl()
    ) {
        self.categoryRepository = categoryRepository
    }
    
    func getEmojiList() async {
        do {
            let response = try await categoryRepository.getEmojiList()
            
            await MainActor.run {
                emojiList = response.groupEmojis
            }
        } catch {
            print("Error getEmojiList: \(error)")
        }
    }
    
    func createCategory(name: String, emojiId: Int) async {
        do {
            try await categoryRepository.createCategory(request: CreateCategoryRequest(name: name, emojiId: emojiId))
        } catch {
            print("Error createCategory: \(error)")
        }
    }
}
