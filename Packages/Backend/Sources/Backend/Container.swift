//
//  Container.swift
//  
//
//  Created by Kamaal M Farah on 31/12/2022.
//

import Swinject
import CDPersist
import Foundation

let container: Container = {
    let container = Container()
    container.register(PersistenceController.self) { (_: Resolver, preview: Bool) in
        if preview {
            return PersistenceController.preview
        }
        return PersistenceController.shared
    }
    return container
}()
