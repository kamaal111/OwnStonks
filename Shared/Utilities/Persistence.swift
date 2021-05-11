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
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let dummyTransactions: [DummyTransaction]
        do {
            dummyTransactions = try decoder.decode([DummyTransaction].self, from: Self.dummyTransactions)
        } catch {
            fatalError("\(error.localizedDescription) ::: \(error)")
        }
        guard let context = result.context else { fatalError("No context") }
        for transaction in dummyTransactions {
            let newTransaction = CoreTransaction(context: context)
            newTransaction.costPerShare = transaction.costPerShare
            newTransaction.createdDate = transaction.createdDate
            newTransaction.id = transaction.id
            newTransaction.name = transaction.name
            newTransaction.shares = transaction.shares
            newTransaction.symbol = transaction.symbol
            newTransaction.transactionDate = transaction.transactionDate
            newTransaction.updatedDate = transaction.updatedDate
        }
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    static let dummyTransactions = """
    [
        {
            "id": "81da49ba-a560-4022-992e-0faef20a6a59",
            "name": "Apple",
            "cost_per_share: 132,
            "transaction_date": "2021-05-11T17:04:10+0000",
            "shares": 2,
            "created_date": "2021-05-11T17:04:10+0000",
            "symbol": "AAPL",
            "updated_date": "2021-05-11T17:04:10+0000"
        }
    ]
    """.data(using: .utf8)!

    struct DummyTransaction: Codable {
        let id: UUID
        let name: String
        let costPerShare: Double
        let transactionDate: Date
        let shares: Double
        let createdDate: Date
        let symbol: String
        let updatedDate: Date

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case costPerShare = "cost_per_share"
            case transactionDate = "transaction_date"
            case shares
            case createdDate = "created_date"
            case symbol
            case updatedDate = "updated_date"
        }
    }
}
#endif
