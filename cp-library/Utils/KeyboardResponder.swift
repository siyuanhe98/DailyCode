//
//  KeyboardResponder.swift
//  cp-library
//
//  Created by Siyuan He on 4/25/23.
//

import Combine
import SwiftUI

class KeyboardResponder: ObservableObject {
    @Published var currentHeight: CGFloat = 0

    private var notificationCenter: NotificationCenter
    private var cancellableSet: Set<AnyCancellable> = []

    init(center: NotificationCenter = .default) {
        notificationCenter = center

        notificationCenter.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height }
            .assign(to: &$currentHeight)

        notificationCenter.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
            .assign(to: &$currentHeight)
    }
}

