//
//  PlaygroundCloudDatabaseScreen.swift
//
//
//  Created by Kamaal M Farah on 02/01/2024.
//

import SwiftUI
import KamaalUI
import Transactions
import SharedModels
import PersistentData

private let cloudModelsRecordNames = [AppTransaction.recordName, AppTransactionDataSource.recordName]

struct PlaygroundCloudDatabaseScreen: View {
    var body: some View {
        KScrollableForm {
            ForEach(cloudModelsRecordNames, id: \.self) { name in
                Text(name)
            }
        }
    }
}

#Preview {
    PlaygroundCloudDatabaseScreen()
}
