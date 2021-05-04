//
//  CoreTransaction+extensions.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 03/05/2021.
//

import CoreData

extension CoreTransaction {
    var hasher: Hasher {
        Hasher(
            name: name,
            shares: shares,
            costPerShare: costPerShare,
            transactionDate: transactionDate,
            coreObject: self,
            symbol: symbol)
    }

    static func setTransaction(
        args: Args,
        managedObjectContext: NSManagedObjectContext,
        save: Bool = true) -> Result<CoreTransaction, Error> {
        let stonk = CoreTransaction(context: managedObjectContext)
        stonk.name = args.name
        stonk.costPerShare = args.costPerShare
        stonk.shares = args.shares
        stonk.symbol = args.symbol
        stonk.transactionDate = args.transactionDate
        stonk.createdDate = Date()
        if save {
            do {
                try managedObjectContext.save()
            } catch {
                return .failure(error)
            }
        }
        return .success(stonk)
    }

    struct Hasher: Hashable {
        let name: String
        let shares: Double
        let costPerShare: Double
        let transactionDate: Date
        let symbol: String?
        let coreObject: CoreTransaction

        init(
            name: String,
            shares: Double,
            costPerShare: Double,
            transactionDate: Date,
            coreObject: CoreTransaction,
            symbol: String? = nil) {
            self.name = name
            self.shares = shares
            self.costPerShare = costPerShare
            self.transactionDate = transactionDate
            self.symbol = symbol
            self.coreObject = coreObject
        }
    }

    struct Args {
        let name: String
        let costPerShare: Double
        let shares: Double
        let transactionDate: Date
        let symbol: String?

        init(name: String, costPerShare: Double, shares: Double, transactionDate: Date, symbol: String? = nil) {
            self.name = name
            self.costPerShare = costPerShare
            self.shares = shares
            self.transactionDate = transactionDate
            self.symbol = symbol
        }
    }
}
