//
//  EmojiModel.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/27/24.
//

struct EmojiModel: Identifiable, Codable {
    let emojiId: Int
    let imageUrl: String
    
    var id: Int { emojiId }
}
