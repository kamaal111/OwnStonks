//
//  FloatingTextField.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 01/05/2021.
//

import SwiftUI

public struct FloatingTextField: View {
    @Binding public var text: String

    public let title: String
    public let textFieldType: TextFieldType

    public init(text: Binding<String>, title: String, textFieldType: TextFieldType = .text) {
        self._text = text
        self.title = title
        self.textFieldType = textFieldType
    }

    public enum TextFieldType {
        case text
        case decimals
        case numbers

        #if canImport(UIKit)
        var keyboardType: UIKeyboardType {
            switch self {
            case .decimals: return .decimalPad
            case .numbers: return .numberPad
            case .text: return .default
            }
        }
        #endif
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            Text(title)
                .foregroundColor($text.wrappedValue.isEmpty ? .secondary : .accentColor)
                .offset(y: $text.wrappedValue.isEmpty ? 0 : -25)
                .scaleEffect($text.wrappedValue.isEmpty ? 1 : 0.75, anchor: .leading)
                .padding(.horizontal, $text.wrappedValue.isEmpty ? 4 : 0)
            #if canImport(UIKit)
            TextField("", text: $text)
                .keyboardType(textFieldType.keyboardType)
            #else
            TextField("", text: $text)
            #endif
        }
        .padding(.top, 12)
        .animation(.spring(response: 0.5))
    }
}

struct FloatingTextField_Previews: PreviewProvider {
    static var previews: some View {
        FloatingTextField(text: .constant(""), title: "Tile")
    }
}
