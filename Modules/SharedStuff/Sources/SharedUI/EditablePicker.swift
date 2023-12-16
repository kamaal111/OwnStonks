//
//  EditablePicker.swift
//
//
//  Created by Kamaal M Farah on 10/12/2023.
//

import SwiftUI
import KamaalUI
import SharedModels

public struct EditablePicker<Item: Hashable & LocalizedItem, PickerItemView: View>: View {
    @Binding var selection: Item

    let label: String
    let isEditing: Bool
    let items: [Item]
    let valueColor: Color
    let pickerItemView: (_ item: Item) -> PickerItemView

    public init(
        selection: Binding<Item>,
        label: String,
        isEditing: Bool,
        items: [Item],
        valueColor: Color = .primary,
        @ViewBuilder pickerItemView: @escaping (_ item: Item) -> PickerItemView
    ) {
        self._selection = selection
        self.label = label
        self.isEditing = isEditing
        self.items = items
        self.valueColor = valueColor
        self.pickerItemView = pickerItemView
    }

    public var body: some View {
        if isEditing {
            KTitledPicker(selection: $selection, title: label, items: items) { item in pickerItemView(item) }
        } else {
            AppLabel(title: label, value: selection.localized, valueColor: valueColor)
        }
    }
}

// #Preview {
//    EditablePicker(
//        selection: .constant(TransactionTypes.buy),
//        label: "Label",
//        isEditing: true,
//        items: TransactionTypes.allCases
//    ) { item in
//        Text(item.localized)
//    }
// }
