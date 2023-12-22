//
//  PlaygroundAppLogoScreen.swift
//
//
//  Created by Kamaal M Farah on 17/12/2023.
//

import SwiftUI
import KamaalUI
import SharedUI
import KamaalUtils
import KamaalPopUp
import KamaalExtensions
import AppIconGenerator

struct PlaygroundAppLogoScreen: View {
    @EnvironmentObject private var kPopUpManager: KPopUpManager

    @State private var viewModel = ViewModel()

    var body: some View {
        KScrollableForm {
            KJustStack {
                logoSection
                customizationSection
            }
            #if os(macOS)
            .padding(.all, .medium)
            .ktakeSizeEagerly(alignment: .topLeading)
            #endif
        }
    }

    private var logoSection: some View {
        KSection(header: "Logo") {
            HStack(alignment: .top) {
                viewModel.previewLogoView
                Spacer()
                VStack(alignment: .leading) {
                    HStack {
                        KFloatingTextField(
                            text: $viewModel.exportLogoSize,
                            title: "Export logo size",
                            textFieldType: .numbers
                        )
                        HStack {
                            Button(action: { viewModel.setRecommendedLogoSize() }) {
                                Text("Logo size")
                                    .foregroundColor(.accentColor)
                            }
                            .disabled(viewModel.disableLogoSizeButton)
                            Button(action: { viewModel.setRecommendedAppIconSize() }) {
                                Text("Icon size")
                                    .foregroundColor(.accentColor)
                            }
                            .disabled(viewModel.disableAppIconSizeButton)
                        }
                        .padding(.bottom, -(AppSizes.small.rawValue))
                    }
                    #if os(macOS)
                    HStack {
                        Button(action: {
                            Task {
                                await viewModel.exportLogo()
                                kPopUpManager.showPopUp(
                                    style: .bottom(title: "Saved logo successfully", type: .success, description: nil),
                                    timeout: 3
                                )
                            }
                        }) {
                            Text("Export logo")
                                .foregroundColor(.accentColor)
                        }
                        Button(action: {
                            Task {
                                await viewModel.exportLogoAsIconSet()
                                kPopUpManager.showPopUp(
                                    style: .bottom(
                                        title: "Saved AppIconSet successfully",
                                        type: .success,
                                        description: nil
                                    ),
                                    timeout: 3
                                )
                            }
                        }) {
                            Text("Export logo as IconSet")
                                .foregroundColor(.accentColor)
                        }
                    }
                    #endif
                }
            }
        }
    }

    private var customizationSection: some View {
        KSection(header: "Customization") {
            AppLogoColorFormRow(title: "Has a background") {
                Toggle(viewModel.hasABackground ? "Yup" : "Nope", isOn: $viewModel.hasABackground)
            }
            .padding(.bottom, .medium)
            .padding(.vertical, .small)
        }
    }
}

extension PlaygroundAppLogoScreen {
    @Observable
    final class ViewModel {
        var hasCurves = true
        var curvedCornersSize: CGFloat = 16
        var hasABackground = true
        var primaryBackgroundColor: Color = .red
        var secondaryBackgroundColor: Color = .yellow
        var chartColor: Color = .black
        var dollarColor: Color = .green
        var exportLogoSize = "400" {
            didSet { exportLogoSizeDidSet() }
        }

        private let previewLogoSize: CGFloat = 150
        private let recommendedLogoSize = "400"
        private let recommendedAppIconSize = "800"
        private let fileManager = FileManager.default

        var previewLogoView: some View {
            logoView(size: previewLogoSize, cornerRadius: hasCurves ? curvedCornersSize : 0)
        }

        var disableLogoSizeButton: Bool {
            exportLogoSize == recommendedLogoSize
        }

        var disableAppIconSizeButton: Bool {
            exportLogoSize == recommendedAppIconSize
        }

        @MainActor
        func setRecommendedLogoSize() {
            withAnimation { exportLogoSize = recommendedLogoSize }
        }

        @MainActor
        func setRecommendedAppIconSize() {
            withAnimation { exportLogoSize = recommendedAppIconSize }
        }

        #if os(macOS)
        func exportLogo() async {
            let logoViewData = await AppIconGenerator.transformViewToPNG(logoToExport)!
            let logoName = "logo.png"
            let panel = try! await SavePanel.save(filename: logoName).get()
            let saveURL = await panel.url!
            if fileManager.fileExists(atPath: saveURL.path) {
                try! fileManager.removeItem(at: saveURL)
            }
            try! logoViewData.write(to: saveURL)
        }

        func exportLogoAsIconSet() async {
            let temporaryDirectory = fileManager.temporaryDirectory
            let appIconSet = try! await AppIconGenerator.makeAppIconSet(to: temporaryDirectory, outOf: logoToExport)
                .get()
            assert(!appIconSet.images.isEmpty)
            let iconSetURL = appIconSet.url!
            defer { try? fileManager.removeItem(atPath: iconSetURL.absoluteString) }

            assert(!((try? fileManager.contentsOfDirectory(atPath: iconSetURL.absoluteString)) ?? []).isEmpty)
            let panel = try! await SavePanel.save(filename: iconSetURL.lastPathComponent).get()
            let saveURL = await panel.url!
            if fileManager.fileExists(atPath: saveURL.path(percentEncoded: true)) {
                try! fileManager.removeItem(at: saveURL)
            }
            try! fileManager.moveItem(atPath: iconSetURL.absoluteString, toPath: saveURL.path(percentEncoded: true))
        }
        #endif

        private var logoToExport: some View {
            let size = Double(exportLogoSize)!.cgFloat
            return logoView(size: size, cornerRadius: curvedCornersSize * (size / previewLogoSize))
        }

        private var backgroundColors: [Color] {
            guard hasABackground else { return [] }
            return [primaryBackgroundColor, secondaryBackgroundColor]
        }

        private func logoView(size: CGFloat, cornerRadius: CGFloat) -> some View {
            AppLogo(
                size: size,
                curvedCornersSize: hasCurves ? cornerRadius : 0,
                backgroundColors: backgroundColors,
                chartColor: chartColor,
                dollarColor: dollarColor
            )
        }

        private func exportLogoSizeDidSet() {
            let filteredExportLogoSize = exportLogoSize.filter(\.isNumber)
            if exportLogoSize != filteredExportLogoSize {
                exportLogoSize = filteredExportLogoSize
            }
        }
    }
}

#Preview {
    PlaygroundAppLogoScreen()
}
