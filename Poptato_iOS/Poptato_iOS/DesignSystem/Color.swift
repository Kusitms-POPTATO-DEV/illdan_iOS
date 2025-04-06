//
//  Color.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/21/24.
//

import SwiftUI
import UIKit

extension UIColor {
    var rgba: Int {
        var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return Int(red * 255.0) << 24 | Int(green * 255.0) << 16 | Int(blue * 255.0) << 8 | Int(alpha * 255.0)
    }

    var alpha: CGFloat {
        return CGFloat(self.rgba & 0xFF) / 255.0
    }

    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = (CGFloat((hex & 0xff0000) >> 16) / 255.0)
        let green = (CGFloat((hex & 0x00ff00) >> 8) / 255.0)
        let blue = (CGFloat(hex & 0x0000ff) / 255.0)
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

// SwiftUI Color 확장
extension Color {
    init(hex: Int) {
        self.init(UIColor(hex: hex))
    }
}

// Gray Scale
extension UIColor {
    static let gray00 = UIColor(hex: 0xFFFFFFFF)
    static let gray05 = UIColor(hex: 0xFFF4F4F6)
    static let gray10 = UIColor(hex: 0xFFE6E6EA)
    static let gray20 = UIColor(hex: 0xFFDBDBE1)
    static let gray30 = UIColor(hex: 0xFFC2C2CC)
    static let gray40 = UIColor(hex: 0xFFA9A9B7)
    static let gray50 = UIColor(hex: 0xFF9090A2)
    static let gray60 = UIColor(hex: 0xFF77778D)
    static let gray70 = UIColor(hex: 0xFF616175)
    static let gray80 = UIColor(hex: 0xFF4D4D5C)
    static let gray90 = UIColor(hex: 0xFF383843)
    static let gray95 = UIColor(hex: 0xFF2E2E38)
    static let gray100 = UIColor(hex: 0xFF23232A)
}

// Primary Colors
extension UIColor {
    static let primary0 = UIColor(hex: 0xFFE0FAFA)
    static let primary10 = UIColor(hex: 0xFFB4F3F3)
    static let primary20 = UIColor(hex: 0xFF88ECEC)
    static let primary30 = UIColor(hex: 0xFF5DE5E5)
    static let primary40 = UIColor(hex: 0xFF30DEDE)
    static let primary50 = UIColor(hex: 0xFF1EBDBD)
    static let primary60 = UIColor(hex: 0xFF179191)
    static let primary70 = UIColor(hex: 0xFF106565)
    static let primary80 = UIColor(hex: 0xFF093939)
    
    static let primary90 = UIColor(hex: 0xFF0E5D50)
    static let primary100 = UIColor(hex: 0xFF07312A)
}

// Danger Colors
extension UIColor {
    static let danger10 = UIColor(hex: 0xFFFEECEF)
    static let danger20 = UIColor(hex: 0xFFFDDEE3)
    static let danger30 = UIColor(hex: 0xFFF9AEBB)
    static let danger40 = UIColor(hex: 0xFFF67F92)
    static let danger50 = UIColor(hex: 0xFFF24D69)
    static let danger60 = UIColor(hex: 0xFFE22C4A)
    static let danger70 = UIColor(hex: 0xFFC11A36)
}

// Warning Colors
extension UIColor {
    static let warning10 = UIColor(hex: 0xFFFDDEE9)
    static let warning20 = UIColor(hex: 0xFFF9AECA)
    static let warning30 = UIColor(hex: 0xFFF67FAA)
    static let warning40 = UIColor(hex: 0xFFF24D8A)
    static let warning50 = UIColor(hex: 0xFFEF206C)
    static let warning60 = UIColor(hex: 0xFFC61556)
    static let warning70 = UIColor(hex: 0xFF941443)
}

// KaKao
extension UIColor {
    static let kakaoMain = UIColor(hex: 0xFFFEE500)
}

// ETC Colors
extension UIColor {
    static let bookmark = UIColor(hex: 0xFF294746)
}

// Background Colors
extension UIColor {
    static let bgSnackBar = UIColor(hex: 0xFF121214)
}

// Toast
extension UIColor {
    static let toast = UIColor(hex: 0xFF000000)
}

// SwiftUI Color 대응
extension Color {
    static let gray00 = Color(uiColor: .gray00)
    static let gray05 = Color(uiColor: .gray05)
    static let gray10 = Color(uiColor: .gray10)
    static let gray20 = Color(uiColor: .gray20)
    static let gray30 = Color(uiColor: .gray30)
    static let gray40 = Color(uiColor: .gray40)
    static let gray50 = Color(uiColor: .gray50)
    static let gray60 = Color(uiColor: .gray60)
    static let gray70 = Color(uiColor: .gray70)
    static let gray80 = Color(uiColor: .gray80)
    static let gray90 = Color(uiColor: .gray90)
    static let gray95 = Color(uiColor: .gray95)
    static let gray100 = Color(uiColor: .gray100)

    static let primary0 = Color(uiColor: .primary0)
    static let primary10 = Color(uiColor: .primary10)
    static let primary20 = Color(uiColor: .primary20)
    static let primary30 = Color(uiColor: .primary30)
    static let primary40 = Color(uiColor: .primary40)
    static let primary50 = Color(uiColor: .primary50)
    static let primary60 = Color(uiColor: .primary60)
    static let primary70 = Color(uiColor: .primary70)
    static let primary80 = Color(uiColor: .primary80)
    static let primary90 = Color(uiColor: .primary90)
    static let primary100 = Color(uiColor: .primary100)

    static let danger10 = Color(uiColor: .danger10)
    static let danger20 = Color(uiColor: .danger20)
    static let danger30 = Color(uiColor: .danger30)
    static let danger40 = Color(uiColor: .danger40)
    static let danger50 = Color(uiColor: .danger50)
    static let danger60 = Color(uiColor: .danger60)
    static let danger70 = Color(uiColor: .danger70)

    static let warning10 = Color(uiColor: .warning10)
    static let warning20 = Color(uiColor: .warning20)
    static let warning30 = Color(uiColor: .warning30)
    static let warning40 = Color(uiColor: .warning40)
    static let warning50 = Color(uiColor: .warning50)
    static let warning60 = Color(uiColor: .warning60)
    static let warning70 = Color(uiColor: .warning70)

    static let kakaoMain = Color(uiColor: .kakaoMain)
    static let bookmark = Color(uiColor: .bookmark)
    static let bgSnackBar = Color(uiColor: .bgSnackBar)
    
    static let kakaoLogin = LinearGradient(
        gradient: Gradient(colors: [
            Color(hex: 0x1E1E20).opacity(0.5),
            Color(hex: 0x1E1E20)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
    static let splash = LinearGradient(
        gradient: Gradient(colors: [
            Color(hex: 0x1E1E20).opacity(0.1),
            Color(hex: 0x1CB59C)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let toast = Color(uiColor: .toast)
}
