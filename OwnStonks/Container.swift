//
//  Container.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 31/12/2022.
//

import Backend
import Swinject

let container = {
    let container = Container()
    container.register(Backend.self) { (_: Resolver, preview: Bool) in
        if preview {
            return .preview
        }
        return .shared
    }
    return container
}()
