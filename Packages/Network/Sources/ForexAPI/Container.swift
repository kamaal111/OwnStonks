//
//  Container.swift
//  
//
//  Created by Kamaal M Farah on 01/01/2023.
//

import Swinject
import XiphiasNet
import Foundation

private var xiphiasNet: XiphiasNet?

let container: Container = {
    let container = Container()
    container.register(XiphiasNet.self) { (_: Resolver, urlSession: URLSession) in
        if let xiphiasNet {
            return xiphiasNet
        }

        xiphiasNet = XiphiasNet(urlSession: urlSession)
        return xiphiasNet!
    }
    return container
}()
