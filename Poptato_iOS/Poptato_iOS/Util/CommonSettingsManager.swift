//
//  CommonSettingsManager.swift
//  Poptato_iOS
//
//  Created by 현수 노트북 on 2/20/25.
//

import Combine
import SwiftUI

final class CommonSettingsManager: ObservableObject {
    static let shared = CommonSettingsManager()
    
    @Published var deadlineDateMode: Bool
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        self.deadlineDateMode = AppStorageManager.deadlineDateMode
        
        AppStorageManager.deadlineDateModePublisher
                    .sink { [weak self] newValue in
                        self?.deadlineDateMode = newValue
                    }
                    .store(in: &cancellables)
    }
    
    func toggleDeadlineMode() {
        AppStorageManager.deadlineDateMode = !deadlineDateMode
    }
}
