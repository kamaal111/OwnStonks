//
//  TitledPicker.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 30/12/2022.
//

import SwiftUI
import OSLocales

struct TitledPicker<Items: Hashable, PickerItemView: View>: View {
    @Binding var selection: Items

    let title: String
    let items: [Items]
    let pickerItemView: (_ item: Items) -> PickerItemView

    init(
        selection: Binding<Items>,
        title: String,
        items: [Items],
        @ViewBuilder pickerItemView: @escaping (_ item: Items) -> PickerItemView) {
            self._selection = selection
            self.title = title
            self.items = items
            self.pickerItemView = pickerItemView
        }

    init(
        selection: Binding<Items>,
        localized: OSLocales.Keys,
        items: [Items],
        @ViewBuilder pickerItemView: @escaping (_ item: Items) -> PickerItemView) {
            self.init(
                selection: selection,
                title: OSLocales.getText(localized),
                items: items,
                pickerItemView: pickerItemView)
        }

    var body: some View {
        TitledView(title: title) {
            Picker("", selection: $selection) {
                ForEach(items, id: \.self) { item in
                    pickerItemView(item)
                        .tag(item)
                }
            }
            .labelsHidden()
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
