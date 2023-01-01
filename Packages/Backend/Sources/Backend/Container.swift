//
//  Container.swift
//  
//
//  Created by Kamaal M Farah on 31/12/2022.
//

import Swinject
import ForexAPI
import CDPersist
import Foundation

let container: Container = {
    let container = Container()
    container.register(PersistenceController.self) { (_: Resolver, preview: Bool) in
        if preview {
            return .preview
        }
        return .shared
    }
    container.register(ForexAPI.self) { (_: Resolver, preview: Bool) in
        if preview {
            return .preview
        }
        return .shared
    }
    return container
}()
