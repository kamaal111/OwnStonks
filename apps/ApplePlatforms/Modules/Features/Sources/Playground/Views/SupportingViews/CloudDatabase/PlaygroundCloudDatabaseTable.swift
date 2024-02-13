//
//  PlaygroundCloudDatabaseTable.swift
//
//
//  Created by Kamaal M Farah on 05/01/2024.
//

import SwiftUI
import KamaalUI
import CloudKit
import KamaalExtensions

struct PlaygroundCloudDatabaseTable: View {
    let keys: [String]
    let records: [CKRecord]
    let isLoading: Bool

    var body: some View {
        ZStack {
            HStack {
                ScrollView(.horizontal) {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(keysWithRecordID, id: \.self) { key in
                            HStack {
                                Text(key)
                                    .font(.headline)
                                    .bold()
                                if keysWithRecordID.last != key {
                                    Spacer()
                                    RoundedRectangle(cornerSize: .squared(4))
                                        .frame(width: 2)
                                }
                            }
                            .background(content: { Color.secondary.opacity(0.4) })
                        }
                        ForEach(records, id: \.self) { record in
                            PlaygroundCloudDatabaseDataRow(keys: keysWithRecordID, record: record)
                        }
                    }
                }
            }
            if isLoading {
                KLoading()
            }
        }
    }

    private var keysWithRecordID: [String] {
        ["recordName"].concat(keys)
    }

    private var columns: [GridItem] {
        (0 ..< keysWithRecordID.count)
            .map { _ in
                GridItem(.flexible(minimum: 100))
            }
    }
}

#Preview {
    PlaygroundCloudDatabaseTable(keys: [], records: [], isLoading: false)
}
