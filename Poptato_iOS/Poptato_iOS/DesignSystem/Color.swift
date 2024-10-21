//
//  Color.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 10/21/24.
//

import SwiftUI
import UIKit

extension Color {
    static let gray100 = Color(uiColor: .gray100)
}

extension UIColor {
    var rgba: Int {
            get {
                var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
                self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

                return Int(red * 255.0) << 24 | Int(green * 255.0) << 16 | Int(blue * 255.0) << 8 | Int(alpha * 255.0)
            }
        }

        var alpha: CGFloat {
            get {
                return CGFloat(self.rgba & 0xFF) / 255.0
            }
        }

        convenience init(hex: Int, alpha: CGFloat = 1.0) {
            let red = (CGFloat((hex & 0xff0000) >> 16) / 255.0)
            let green = (CGFloat((hex & 0x00ff00) >> 8) / 255.0)
            let blue = (CGFloat(hex & 0x0000ff) / 255.0)
            self.init(red: red, green: green, blue: blue, alpha: alpha)
        }
}

extension UIColor {
    static let gray100 = UIColor(hex: 0x1E1E20)
}
