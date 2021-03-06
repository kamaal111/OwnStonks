//
//  FloatingDatePicker.swift
//  
//
//  Created by Kamaal Farah on 04/05/2021.
//

import SwiftUI
import StonksLocale

public struct FloatingDatePicker: View {
    @Binding public var value: Date

    public let title: String
    public let onChange: (_ newValue: Date) -> Void

    public init(value: Binding<Date>, title: String, onChange: @escaping (_ newValue: Date) -> Void = { _ in }) {
        self._value = value
        self.title = title
        self.onChange = onChange
    }

    public init(
        value: Binding<Date>,
        title: StonksLocale.Keys,
        onChange: @escaping (_ newValue: Date) -> Void = { _ in }) {
        self._value = value
        self.title = title.localized
        self.onChange = onChange
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            Text(title)
                .foregroundColor(.accentColor)
                .offset(y: -25)
                .scaleEffect(0.75, anchor: .leading)
                .padding(.horizontal, 4)
            DatePicker("", selection: $value, displayedComponents: .date)
                .labelsHidden()
        }
        .padding(.top, 12)
        .onChange(of: value, perform: onChange)
    }
}

struct FloatingDatePicker_Previews: PreviewProvider {
    static var previews: some View {
        FloatingDatePicker(value: .constant(Date()), title: "Date", onChange: { _ in })
    }
}
