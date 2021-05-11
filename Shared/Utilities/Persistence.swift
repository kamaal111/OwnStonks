//
//  Persistence.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 03/05/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import CoreData
import PersistanceManager
import ConsoleSwift

struct PersistenceController {
    private let sharedInststance: PersistanceManager

    private init(inMemory: Bool = false) {
        let persistanceContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: Constants.persistentContainerName)
            if inMemory {
                container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
            } else {
                guard let defaultUrl = container.persistentStoreDescriptions.first?.url
                else { fatalError("Default url not found") }
                let defaultStore = NSPersistentStoreDescription(url: defaultUrl)
                defaultStore.configuration = "Default"
                defaultStore.shouldMigrateStoreAutomatically = true
                defaultStore.shouldInferMappingModelAutomatically = true
            }
            container.loadPersistentStores { (_: NSPersistentStoreDescription, error: Error?) in
                if let error = error as NSError? {
                    console.error(Date(), "Unresolved error \(error),", error.userInfo)
                }
            }
            return container
        }()
        self.sharedInststance = PersistanceManager(container: persistanceContainer)
    }

    static let shared = PersistenceController().sharedInststance
}

#if DEBUG
extension PersistenceController {
    static let preview: PersistanceManager = {
        let result = PersistenceController(inMemory: true).sharedInststance
        let dummyTransactions: [DummyTransaction] = [
        ]
        if let context = result.context {
            for transaction in dummyTransactions {
                #error("Not finished")
                let newTransaction = CoreTransaction(context: context)
                newTransaction.costPerShare = transaction.costPerShare
                newTransaction.createdDate = Date()
            }
        }
//        for _ in 0..<10 {
//            let newItem = Item(context: viewContext)
//            newItem.timestamp = Date()
//        }
//        do {
//            try viewContext.save()
//        } catch {
//            // Replace this implementation with code to handle the error appropriately.
//            let nsError = error as NSError
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//        }
        return result
    }()

    struct DummyTransaction {
        let name: String
        let costPerShare: Double
        let transactionDate: Date
        let shares: String
    }
}
#endif
