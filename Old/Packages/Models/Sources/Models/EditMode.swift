//
//  EditMode.swift
//
//
//  Created by Kamaal M Farah on 07/01/2023.
//

import Foundation

#if os(macOS)
public enum EditMode {
    case active
    case inactive

    public var isEditing: Bool {
        self == .active
    }
}
#endif
