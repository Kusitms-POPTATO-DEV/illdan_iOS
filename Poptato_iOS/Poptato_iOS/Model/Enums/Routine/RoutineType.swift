//
//  RoutineType.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 6/6/25.
//

enum RoutineType {
    case WEEKDAY
    case GENERAL
    
    var name: String {
        switch self {
        case .WEEKDAY: "요일 반복"
        case .GENERAL: "일반"
        }
    }
}
