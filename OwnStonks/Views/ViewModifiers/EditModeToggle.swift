//
//  EditModeToggle.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 07/01/2023.
//

import Models
import SwiftUI

extension View {
    func withEditMode() -> some View {
        self
            .modifier(EditModeViewModifier())
    }
}

struct EditModeViewModifier: ViewModifier {
    @State private var editMode: EditMode = .inactive

    func body(content: Content) -> some View {
        content
            #if os(macOS)
            .environment(\.editMode, editMode)
            .onReceive(NotificationCenter.default
                .publisher(for: .editModeChanged), perform: { output in
                    guard let newEditMode = output.object as? EditMode, newEditMode != editMode else { return }

                    withAnimation { editMode = newEditMode }
                })
            #endif
    }
}

#if os(macOS)
struct EditModeKey: EnvironmentKey {
    static let defaultValue: EditMode = .inactive
}

extension EnvironmentValues {
    var editMode: EditMode {
        get { self[EditModeKey.self] }
        set { self[EditModeKey.self] = newValue }
    }
}
#endif
