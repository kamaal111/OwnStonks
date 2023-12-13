//
//  UserSettings.swift
//
//
//  Created by Kamaal M Farah on 13/12/2023.
//

import SwiftUI
import Observation
import KamaalSettings

@Observable
public final class UserSettings {
    private(set) var appColor = AppColor(
        id: UUID(uuidString: "d3256bc6-84a4-4717-a970-9d2d3a1724b4")!,
        name: NSLocalizedString("Default color", bundle: .module, comment: ""),
        color: Color("AccentColor")
    )

    public init() { }

    var configuration: SettingsConfiguration {
        var feedbackConfiguration: SettingsConfiguration.FeedbackConfiguration?
        if Features.feedback, let feedbackToken = SecretsJSON.shared.content?.githubToken {
            #if os(macOS)
            let deviceLabel = "macOS"
            #else
            let deviceLabel = UIDevice.current.userInterfaceIdiom == .pad ? "iPadOS" : "iOS"
            #endif
            feedbackConfiguration = .init(
                token: feedbackToken,
                username: "kamaal111",
                repoName: "OwnStonks",
                additionalLabels: [deviceLabel, "in app feedback"]
            )
        }
        return SettingsConfiguration(feedback: feedbackConfiguration, color: colorConfiguration)
    }

    private var colorConfiguration: SettingsConfiguration.ColorsConfiguration {
        .init(colors: [appColor], currentColor: appColor)
    }
}
