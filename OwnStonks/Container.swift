//
//  Container.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 31/12/2022.
//

import Backend
import Swinject

let container: Container = {
    let container = Container()
    container.register(Backend.self) { (_: Resolver, preview: Bool) in
        Backend(preview: preview)
    }
    return container
}()
