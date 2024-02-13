//
//  PlaygroundCloudDatabaseDataRow.swift
//
//
//  Created by Kamaal M Farah on 05/01/2024.
//

import SwiftUI
import CloudKit
import KamaalPopUp

struct PlaygroundCloudDatabaseDataRow: View {
    @EnvironmentObject private var kPopUpManager: KPopUpManager

    let keys: [String]
    let record: CKRecord

    var body: some View {
        ForEach(uniqueKeys, id: \.self) { key in
            if let value = getValue(by: key) {
                Button(action: { action(with: value) }) {
                    Text(value)
                }
                .buttonStyle(.plain)
            } else {
                Text("null")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var uniqueKeys: [String] {
        let id = record.recordID.recordName
        return keys.map { key in "\(id)#\(key)" }
    }

    private func action(with value: String) {
        Clipboard.copy(value)
        kPopUpManager.showPopUp(
            style: .hud(title: "Copied '\(value)'", systemImageName: "doc.on.clipboard", description: nil),
            timeout: 4
        )
    }

    private func getValue(by key: String) -> String? {
        let key = key.split(separator: "#").dropFirst().joined()
        if key == "recordName" {
            return record.recordID.recordName
        }

        guard let value = record[key] else { return nil }
        return "\(value as Any)"
    }
}

struct Clipboard {
    init() { }

    static func copy(_ value: String) {
        #if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(value, forType: .string)
        #else
        let pasteboard = UIPasteboard.general
        pasteboard.string = value
        #endif
    }
}

// #Preview {
//    PlaygroundCloudDatabaseDataRow(keys: [], record: )
// }
