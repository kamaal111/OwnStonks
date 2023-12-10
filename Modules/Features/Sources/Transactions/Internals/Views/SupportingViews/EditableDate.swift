//
//  EditableDate.swift
//
//
//  Created by Kamaal M Farah on 10/12/2023.
//

import SwiftUI
import KamaalUI

struct EditableDate: View {
    @Binding var date: Date

    let label: String
    let isEditing: Bool

    var body: some View {
        if isEditing {
            KFloatingDatePicker(
                value: $date,
                title: label,
                displayedComponents: [.date]
            )
        } else {
            AppLabel(title: label, value: Self.dateFormatter.string(from: date))
        }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}

#Preview {
    EditableDate(date: .constant(Date(timeIntervalSince1970: 1_702_242_946)), label: "Dater", isEditing: false)
}
