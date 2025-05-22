//
//  PoaptatoType.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/23/24.
//
import SwiftUI

struct PoptatoTypo {
    static let pretendardBlack = "Pretendard-Black"
    static let pretendardBold = "Pretendard-Bold"
    static let pretendardExtraBold = "Pretendart-ExtraBold"
    static let pretendardExtraLight = "Pretendard-ExtraLight"
    static let pretendardLight = "Pretendard-Light"
    static let pretendardMedium = "Pretendard-Medium"
    static let pretendardRegular = "Pretendard-Regular"
    static let pretendardSemiBold = "Pretendard-SemiBold"
    static let pretendardThin = "Pretendard-Thin"

    static let xxxLSemiBold: Font = .custom(pretendardSemiBold, size: 24).weight(.semibold)
    static let xxxLMedium: Font = .custom(pretendardMedium, size: 24).weight(.medium)
    static let xxxLRegular: Font = .custom(pretendardRegular, size: 24).weight(.regular)

    static let xxLSemiBold: Font = .custom(pretendardSemiBold, size: 22).weight(.semibold)
    static let xxLMedium: Font = .custom(pretendardMedium, size: 22).weight(.medium)
    static let xxLRegular: Font = .custom(pretendardRegular, size: 22).weight(.regular)

    static let xLSemiBold: Font = .custom(pretendardSemiBold, size: 20).weight(.semibold)
    static let xLMedium: Font = .custom(pretendardMedium, size: 20).weight(.medium)
    static let xLRegular: Font = .custom(pretendardRegular, size: 20).weight(.regular)

    static let lgBold: Font = .custom(pretendardBold, size: 18).weight(.bold)
    static let lgSemiBold: Font = .custom(pretendardSemiBold, size: 18).weight(.semibold)
    static let lgMedium: Font = .custom(pretendardMedium, size: 18).weight(.medium)
    static let lgRegular: Font = .custom(pretendardRegular, size: 18).weight(.regular)

    static let mdSemiBold: Font = .custom(pretendardSemiBold, size: 16).weight(.semibold)
    static let mdMedium: Font = .custom(pretendardMedium, size: 16).weight(.medium)
    static let mdRegular: Font = .custom(pretendardRegular, size: 16).weight(.regular)

    static let smSemiBold: Font = .custom(pretendardSemiBold, size: 14).weight(.semibold)
    static let smMedium: Font = .custom(pretendardMedium, size: 14).weight(.medium)
    static let smRegular: Font = .custom(pretendardRegular, size: 14).weight(.regular)

    static let xsSemiBold: Font = .custom(pretendardSemiBold, size: 12).weight(.semibold)
    static let xsMedium: Font = .custom(pretendardMedium, size: 12).weight(.medium)
    static let xsRegular: Font = .custom(pretendardRegular, size: 12).weight(.regular)
    
    static let calRegular: Font = .custom(pretendardRegular, size: 10).weight(.regular)
    static let calMedium: Font = .custom(pretendardMedium, size: 10).weight(.medium)
    static let calSemiBold: Font = .custom(pretendardSemiBold, size: 10).weight(.semibold)
}
