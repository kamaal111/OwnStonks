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
import KamaalPopUp
import Transactions
import SharedModels
import PersistentData

struct PlaygroundCloudDatabaseScreen: View {
    @EnvironmentObject private var kPopUpManager: KPopUpManager

    @State private var selectedCloudModel: CloudModels = .transaction
    @State private var fetchedRecords: [CKRecord] = []
    @State private var loading = false
    @State private var filterQuery = ""

    var body: some View {
        KScrollableForm {
            VStack {
                KTitledPicker(selection: $selectedCloudModel, title: "Model", items: CloudModels.allCases) { item in
                    Text(item.recordName)
                }
                HStack {
                    KFloatingTextField(text: $filterQuery, title: "Filter query")
                    Button(action: { fetchData() }, label: {
                        Text("Fetch")
                    })
                    .onSubmit { fetchData() }
                    .padding(.top, 12)
                }
            }
            .disabled(loading)
            .padding(.horizontal, .medium)
            PlaygroundCloudDatabaseTable(keys: selectedCloudModel.keys, records: fetchedRecords, isLoading: loading)
                .padding(.horizontal, .medium)
        }
        .padding(.vertical, .medium)
        .onChange(of: selectedCloudModel) { _, _ in resetRecords() }
    }

    private func fetchData() {
        guard !loading else { return }

        Task {
            await withLoading {
                let filterQuery = filterQuery.trimmingByWhitespacesAndNewLines

                do {
                    if filterQuery.isEmpty {
                        fetchedRecords = try await PersistentData.shared.listICloud(of: selectedCloudModel.model)
                    } else {
                        fetchedRecords = try await PersistentData.shared.filterICloud(
                            of: selectedCloudModel.model,
                            by: NSPredicate(format: filterQuery)
                        )
                    }
                } catch {
                    kPopUpManager.showPopUp(
                        style: .bottom(title: error.localizedDescription, type: .error, description: nil),
                        timeout: 4
                    )
                }
            }
        }
    }

    private func resetRecords() {
        fetchedRecords = []
        filterQuery = ""
    }

    private func withLoading(completion: () async -> Void) async {
        loading = true
        await completion()
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
