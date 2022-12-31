//
//  OSPicker.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 30/12/2022.
//

import Models
import SwiftUI

struct OSPicker<Item: Hashable, PickerItemView: View>: View {
    @Binding var selection: Item

    let items: [Item]
    let pickerItemView: (_ item: Item) -> PickerItemView

    init(selection: Binding<Item>, items: [Item], pickerItemView: @escaping (_: Item) -> PickerItemView) {
        self._selection = selection
        self.items = items
        self.pickerItemView = pickerItemView
    }

    var body: some View {
        Picker("", selection: $selection) {
            ForEach(items, id: \.self) { item in
                pickerItemView(item)
                    .tag(item)
            }
        }
        .labelsHidden()
    }
}

struct OSPicker_Previews: PreviewProvider {
    static var previews: some View {
        OSPicker(selection: .constant(TransactionTypes.buy), items: TransactionTypes.allCases) { item in
            Text(item.localized)
        }
    }
}
