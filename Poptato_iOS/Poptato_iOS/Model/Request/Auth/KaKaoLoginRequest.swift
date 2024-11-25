//
//  KaKaoLoginRequest.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/26/24.
//

struct KaKaoLoginRequest: Codable {
    let socialType: String
    let accessToken: String
    let mobileType: String = "IOS"
    let clientId: String = "12345"
}
