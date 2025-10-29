//
//  ReissueTokenRequest.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 3/1/25.
//

struct ReissueTokenRequest: Encodable {
    let accessToken: String
    let refreshToken: String
    let clientId: String
    let mobileType: String = "IOS"
}
