//
//  EditableDate.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 31/12/2022.
//

import SwiftUI
import SalmonUI
import ZaWarudo
import OSLocales

struct EditableDate: View {
    @Binding var date: Date

    let title: String
    let isEditing: Bool

    init(date: Binding<Date>, title: String, isEditing: Bool) {
        self._date = date
        self.title = title
        self.isEditing = isEditing
    }

    init(date: Binding<Date>, localized: OSLocales.Keys, isEditing: Bool) {
        self.init(date: date, title: OSLocales.getText(localized), isEditing: isEditing)
    }

    var body: some View {
        if isEditing {
            KFloatingDatePicker(value: $date, title: title)
                .ktakeWidthEagerly(alignment: .leading)
        } else {
            OSText("\(title): \(Self.dateFormatter.string(from: date))")
                .ktakeWidthEagerly(alignment: .leading)
        }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}

struct EditableDate_Previews: PreviewProvider {
    static var previews: some View {
        EditableDate(date: .constant(Current.date()), title: "Title", isEditing: false)
    }
}
