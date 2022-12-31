//
//  TitledPicker.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 30/12/2022.
//

import Models
import SwiftUI
import OSLocales

struct TitledPicker<Item: Hashable, PickerItemView: View>: View {
    @Binding var selection: Item

    let title: String
    let items: [Item]
    let pickerItemView: (_ item: Item) -> PickerItemView

    init(
        selection: Binding<Item>,
        title: String,
        items: [Item],
        @ViewBuilder pickerItemView: @escaping (_ item: Item) -> PickerItemView) {
            self._selection = selection
            self.title = title
            self.items = items
            self.pickerItemView = pickerItemView
        }

    init(
        selection: Binding<Item>,
        localized: OSLocales.Keys,
        items: [Item],
        @ViewBuilder pickerItemView: @escaping (_ item: Item) -> PickerItemView) {
            self.init(
                selection: selection,
                title: OSLocales.getText(localized),
                items: items,
                pickerItemView: pickerItemView)
        }

    var body: some View {
        TitledView(title: title) {
            OSPicker(selection: $selection, items: items, pickerItemView: pickerItemView)
        }
    }
}

struct TitledPicker_Previews: PreviewProvider {
    static var previews: some View {
        TitledPicker(
            selection: .constant(TransactionTypes.buy),
            title: "Type",
            items: TransactionTypes.allCases) { item in
                Text(item.localized)
            }
    }
}
