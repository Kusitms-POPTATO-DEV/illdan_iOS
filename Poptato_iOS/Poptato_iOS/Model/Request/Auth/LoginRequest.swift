//
//  KaKaoLoginRequest.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/26/24.
//

struct LoginRequest: Codable {
    let socialType: String
    let accessToken: String
    let mobileType: String
    let clientId: String
}
