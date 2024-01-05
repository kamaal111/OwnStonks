//
//  PlaygroundCloudDatabaseScreen.swift
//
//
//  Created by Kamaal M Farah on 02/01/2024.
//

import SwiftUI
import SharedUI
import CloudKit
import KamaalUI
import Transactions
import SharedModels
import PersistentData

struct PlaygroundCloudDatabaseScreen: View {
    @State private var selectedCloudModel: CloudModels = .transaction
    @State private var fetchedRecords: [CKRecord] = []
    @State private var loading = false

    var body: some View {
        KScrollableForm {
            HStack {
                KTitledPicker(selection: $selectedCloudModel, title: "Model", items: CloudModels.allCases) { item in
                    Text(item.recordName)
                }
                Button(action: { Task { await fetchData() } }, label: {
                    Text("Fetch")
                })
                .padding(.top, 20)
            }
            .disabled(loading)
            .padding(.horizontal, .medium)
            PlaygroundCloudDatabaseTable(keys: selectedCloudModel.keys, records: fetchedRecords, isLoading: loading)
                .padding(.horizontal, .medium)
        }
        .padding(.vertical, .medium)
        .onChange(of: selectedCloudModel) { _, _ in
            fetchedRecords = []
        }
    }

    private func fetchData() async {
        loading = true
        fetchedRecords = try! await PersistentData.shared.listICloud(of: selectedCloudModel.model)
        loading = false
    }
}

private enum CloudModels: CaseIterable {
    case transaction
    case transactionDataSource

    var model: any CloudQueryable.Type {
        switch self {
        case .transaction: AppTransaction.self
        case .transactionDataSource: AppTransactionDataSource.self
        }
    }

    var keys: [String] {
        switch self {
        case .transaction: AppTransaction.CloudKeys.allCases.map(\.ckRecordKey)
        case .transactionDataSource: AppTransactionDataSource.CloudKeys.allCases.map(\.ckRecordKey)
        }
    }

    var recordName: String {
        model.recordName
    }
}

#Preview {
    PlaygroundCloudDatabaseScreen()
}
