//
//  CoreTransaction+extensions.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 03/05/2021.
//  Copyright © 2021 Kamaal Farah. All rights reserved.
//

import CoreData

extension CoreTransaction {
    var initialPortfolioItem: PortfolioItem {
        PortfolioItem(coreObject: self)
    }

    var totalPrice: Double {
        shares * costPerShare
    }

    static func setTransaction(
        args: Args,
        managedObjectContext: NSManagedObjectContext,
        save: Bool = true) -> Result<CoreTransaction, Error> {
        let transaction = CoreTransaction(context: managedObjectContext)
        transaction.id = UUID()
        transaction.name = args.name
        transaction.costPerShare = args.costPerShare
        transaction.shares = args.shares
        transaction.symbol = args.symbol
        transaction.transactionDate = args.transactionDate
        transaction.createdDate = Date()
        if save {
            do {
                try managedObjectContext.save()
            } catch {
                return .failure(error)
            }
        }
        return .success(transaction)
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
