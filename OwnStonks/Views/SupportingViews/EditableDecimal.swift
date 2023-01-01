//
//  EditableDecimal.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 01/01/2023.
//

import SwiftUI
import SalmonUI
import OSLocales

struct EditableDecimal: View {
    @Binding var value: Double

    let title: String
    let isEditing: Bool

    init(value: Binding<Double>, title: String, isEditing: Bool) {
        self._value = value
        self.title = title
        self.isEditing = isEditing
    }

    init(value: Binding<Double>, localized: OSLocales.Keys, isEditing: Bool) {
        self.init(value: value, title: OSLocales.getText(localized), isEditing: isEditing)
    }

    var body: some View {
        if isEditing {
            KEnforcedFloatingDecimalField(value: $value, title: title)
        } else {
            OSText("\(title): \(value)")
                .ktakeWidthEagerly(alignment: .leading)
        }
    }
}

struct EditableDecimal_Previews: PreviewProvider {
    static var previews: some View {
        EditableDecimal(value: .constant(0.012), title: "Title", isEditing: true)
    }
}
