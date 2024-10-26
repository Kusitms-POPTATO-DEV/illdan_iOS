//
//  KaKaoLoginResponse.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/26/24.
//

struct KaKaoLoginResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let isNewUser: Bool
    let userId: Int
}
