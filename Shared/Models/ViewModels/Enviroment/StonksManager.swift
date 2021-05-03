//
//  StonksManager.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 03/05/2021.
//

import Combine
import ConsoleSwift
import Foundation

final class StonksManager: ObservableObject {

    @Published private(set) var stonks: [CoreStonk] = []

    private let persistenceController = PersistenceController.shared

    init() {
        let fetchResult = persistenceController.fetch(CoreStonk.self)
        switch fetchResult {
        case .failure(let failure):
            console.error(Date(), failure.localizedDescription, failure)
            return
        case .success(let success):
            if let success = success {
                self.stonks = success
            }
        }
    }

    func setStonk(with args: CoreStonk.Args) {
        let stonkResult = CoreStonk.setStonk(args: args, managedObjectContext: persistenceController.context!)
        let stonk: CoreStonk
        switch stonkResult {
        case .failure(let failure):
            console.error(Date(), failure.localizedDescription, failure)
            return
        case .success(let success):
            stonk = success
        }
        stonks.append(stonk)
    }

}
