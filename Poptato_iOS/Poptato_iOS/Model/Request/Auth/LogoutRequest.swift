//
//  LogoutRequest.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 3/12/25.
//

struct LogoutRequest: Encodable {
    let clientId: String?
    let mobileType: String = "IOS"
}
