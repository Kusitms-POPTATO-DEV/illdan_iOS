//
//  DeleteAccountRequest.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 3/12/25.
//

struct DeleteAccountRequest: Codable {
    let reasons: [String]?
    let userInputReason: String?
}
