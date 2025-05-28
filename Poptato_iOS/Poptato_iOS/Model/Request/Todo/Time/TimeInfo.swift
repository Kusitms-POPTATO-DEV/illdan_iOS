//
//  TimeInfo.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 5/23/25.
//

struct TimeInfo {
    let meridiem: String
    let hour: Int
    let minute: Int
}

struct TodoTimeRequest: Codable {
    let todoTime: String?
}
