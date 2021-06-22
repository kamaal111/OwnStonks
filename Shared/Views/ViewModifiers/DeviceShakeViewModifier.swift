//
//  DeviceShakeViewModifier.swift
//  OwnStonks (iOS)
//
//  Created by Kamaal Farah on 22/06/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import SwiftUI

private struct DeviceShakeViewModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: .deviceDidShake), perform: { _ in
                action()
            })
    }
}

extension UIWindow {
    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: .deviceDidShake, object: nil)
        }
     }
}

extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(DeviceShakeViewModifier(action: action))
    }
}
