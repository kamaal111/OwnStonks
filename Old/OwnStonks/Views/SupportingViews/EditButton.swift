//
//  EditButton.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 07/01/2023.
//

import Models
import SwiftUI

#if os(macOS)
struct EditButton: View {
    @Environment(\.editMode) var editMode

    var body: some View {
        Button(action: {
            NotificationCenter.default.post(
                name: .editModeChanged,
                object: editMode.isEditing ? EditMode.inactive : EditMode.active
            )
        }) {
            OSText(localized: editMode.isEditing ? .DONE : .EDIT)
                .foregroundColor(.accentColor)
        }
    }
}

struct EditButton_Previews: PreviewProvider {
    static var previews: some View {
        EditButton()
    }
}
#endif
