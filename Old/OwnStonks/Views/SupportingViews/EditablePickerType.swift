//
//  EditablePickerType.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 01/01/2023.
//

import Models
import SwiftUI
import SalmonUI
import OSLocales

struct EditablePickerType<Item: Hashable & Localized, PickerItemView: View>: View {
    @Binding var selection: Item

    let title: String
    let items: [Item]
    let isEditing: Bool
    let pickerItemView: (_ item: Item) -> PickerItemView

    init(
        selection: Binding<Item>,
        title: String,
        items: [Item],
        isEditing: Bool,
        @ViewBuilder pickerItemView: @escaping (_ item: Item) -> PickerItemView
    ) {
        self._selection = selection
        self.title = title
        self.items = items
        self.isEditing = isEditing
        self.pickerItemView = pickerItemView
    }

    init(
        selection: Binding<Item>,
        localized: OSLocales.Keys,
        items: [Item],
        isEditing: Bool,
        @ViewBuilder pickerItemView: @escaping (_ item: Item) -> PickerItemView
    ) {
        self.init(
            selection: selection,
            title: OSLocales.getText(localized),
            items: items,
            isEditing: isEditing,
            pickerItemView: pickerItemView
        )
    }

    var body: some View {
        if isEditing {
            TitledPicker(selection: $selection, title: title, items: items, pickerItemView: pickerItemView)
        } else {
            OSText("\(title): \(selection.localized)")
                .ktakeWidthEagerly(alignment: .leading)
        }
    }
}

#if DEBUG
struct EditablePickerType_Previews: PreviewProvider {
    static var previews: some View {
        EditablePickerType(
            selection: .constant(TransactionTypes.sell),
            title: "Title",
            items: TransactionTypes.allCases,
            isEditing: true
        ) { item in
            Text(item.localized)
        }
    }
}
#endif
