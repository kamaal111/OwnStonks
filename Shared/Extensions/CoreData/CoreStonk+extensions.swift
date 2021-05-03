//
//  CoreStonk+extensions.swift
//  OwnStonks
//
//  Created by Kamaal Farah on 03/05/2021.
//

import CoreData

extension CoreStonk {
    var stonksData: StonksData {
        StonksData(name: name, shares: shares, costs: costs, symbol: symbol)
    }

    static func setStonk(args: Args, managedObjectContext: NSManagedObjectContext, save: Bool = true) -> Result<CoreStonk, Error> {
        let stonk = CoreStonk(context: managedObjectContext)
        stonk.name = args.name
        stonk.costs = args.costs
        stonk.shares = args.shares
        stonk.symbol = args.symbol
        if save {
            do {
                try managedObjectContext.save()
            } catch {
                return .failure(error)
            }
        }
        return .success(stonk)
    }

    struct Args {
        let name: String
        let costs: Double
        let shares: Double
        let symbol: String?

        init(name: String, costs: Double, shares: Double, symbol: String? = nil) {
            self.name = name
            self.costs = costs
            self.shares = shares
            self.symbol = symbol
        }
    }
}
