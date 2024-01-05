//
//  PlaygroundCloudDatabaseDataRow.swift
//
//
//  Created by Kamaal M Farah on 05/01/2024.
//

import SwiftUI
import CloudKit

struct PlaygroundCloudDatabaseDataRow: View {
    let keys: [String]
    let record: CKRecord

    var body: some View {
        ForEach(uniqueKeys, id: \.self) { key in
            if let value = getValue(by: key) {
                Text(value)
            } else {
                Text("null")
                    .foregroundStyle(.secondary)
            }
        }
    }

    var uniqueKeys: [String] {
        let id = record.recordID.recordName
        return keys.map { key in "\(id)#\(key)" }
    }

    private func getValue(by key: String) -> String? {
        let key = key.split(separator: "#").dropFirst().joined()
        guard let value = record[key] else { return nil }
        return "\(value as Any)"
    }
}

// #Preview {
//    PlaygroundCloudDatabaseDataRow(keys: [], record: )
// }
