//
//  ZaWarudo.swift
//
//
//  Created by Kamaal M Farah on 31/12/2022.
//

import Foundation

/// Current world
public var Current = ZaWarudo()

/// Object to infuluence za warudo in anyway.
///
/// Inspired by: [How To Control The World - Stephen Celis](https://vimeo.com/291588126)
///
/// Is that a JoJo reference?
public struct ZaWarudo {
    public var date: () -> Date = {
        Date()
    }

    public var uuid: () -> UUID = {
        UUID()
    }
}
