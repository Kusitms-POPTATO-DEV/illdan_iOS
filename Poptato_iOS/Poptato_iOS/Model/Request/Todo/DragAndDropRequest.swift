//
//  DragAndDropRequest.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 11/10/24.
//

struct DragAndDropRequest: Codable {
    let type: String
    let todoIds: Array<Int>
}
