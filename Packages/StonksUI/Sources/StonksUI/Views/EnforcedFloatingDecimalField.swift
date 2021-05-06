//
//  EnforcedFloatingDecimalField.swift
//  
//
//  Created by Kamaal M Farah on 02/05/2021.
//

import SwiftUI

@available(macOS 11.0, iOS 14.0, *)
public struct EnforcedFloatingDecimalField: View {
    @State private var text = ""

    @Binding public var value: Double

    public let title: String

    public init(value: Binding<Double>, title: String) {
        self._value = value
        self.title = title
    }

    public var body: some View {
        FloatingTextField(text: $text, title: title, textFieldType: .decimals)
            .onChange(of: text, perform: onValueChange(_:))
    }

    private func onValueChange(_ changedValue: String) {
        if let textAsDouble = Double(changedValue) {
            value = textAsDouble
        } else {
            text = String(changedValue.dropLast())
        }
    }
}

@available(macOS 11.0, iOS 14.0, *)
struct EnforcedFloatingDecimalField_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EnforcedFloatingDecimalField(value: .constant(0), title: "Tile")
                .previewLayout(.sizeThatFits)
                .padding(.vertical, 20)
            EnforcedFloatingDecimalField(value: .constant(0), title: "Tile")
                .previewLayout(.sizeThatFits)
                .padding(.vertical, 20)
                .colorScheme(.dark)
                .background(Color.black)
        }
    }
}
