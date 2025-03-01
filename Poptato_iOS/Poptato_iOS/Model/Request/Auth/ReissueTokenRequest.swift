//
//  ReissueTokenRequest.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 3/1/25.
//

struct ReissueTokenRequest: Codable {
    let accessToken: String
    let refreshToken: String
    let clientId: String
}
