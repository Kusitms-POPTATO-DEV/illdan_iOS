//
//  CommonExtension.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 2/6/25.
//

import SwiftUI

extension NSNotification.Name {
    static let yesterdayTodoCompleted = NSNotification.Name("yesterdayTodoCompleted")
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool,
                             transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
