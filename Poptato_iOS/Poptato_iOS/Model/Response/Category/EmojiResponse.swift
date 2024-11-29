//
//  EmojiResponse.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/27/24.
//

struct EmojiResponse: Codable {
    let groupEmojis: [String : [EmojiModel]]
    let totalPageCount: Int
}
