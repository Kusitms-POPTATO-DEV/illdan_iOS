//
//  ApiResponse.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/26/24.
//

struct ApiResponse<T: Decodable>: Decodable {
    let code: Int
    let status: Int
    let message: String
    let result: T
}
