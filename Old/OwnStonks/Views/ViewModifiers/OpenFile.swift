//
//  OpenFile.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 05/01/2023.
//

import SwiftUI
import Logster

private let logger = Logster(from: OpenFileViewModifier.self)

extension View {
    func openFile(isPresented: Binding<Bool>, onFileOpen: @escaping (_ content: Data) -> Void) -> some View {
        modifier(OpenFileViewModifier(isPresented: isPresented, onFileOpen: onFileOpen))
    }
}

private struct OpenFileViewModifier: ViewModifier {
    @Binding var isPresented: Bool

    let onFileOpen: (_ content: Data) -> Void

    init(isPresented: Binding<Bool>, onFileOpen: @escaping (_ content: Data) -> Void) {
        self._isPresented = isPresented
        self.onFileOpen = onFileOpen
    }

    func body(content: Content) -> some View {
        content
        #if canImport(UIKit)
        .sheet(isPresented: $isPresented, content: {
            DocumentPickerView(isPresented: $isPresented, onFileOpen: onFileOpen)
        })
        #else
            .onChange(of: isPresented, perform: { newValue in
                guard newValue else { return }

                let panel = NSOpenPanel()
                panel.allowsMultipleSelection = false
                panel.canChooseDirectories = false

                let status = panel.runModal()
                if status != .OK {
                    switch status {
                    case .abort:
                        logger.info("aborted file selection")
                    case .continue:
                        logger.info("continueing or what!")
                    case .stop:
                        logger.info("stopping or what!")
                    default:
                        assertionFailure("unknown case")
                    }
                    isPresented = false
                    return
                }

                guard let url = panel.url else {
                    logger.error("URL not found")
                    assertionFailure("URL not found")
                    return
                }

                let content: Data?
                do {
                    content = try SecureFileOpener.readData(from: url)
                } catch {
                    logger.error(label: "Failed to load file", error: error)
                    isPresented = false
                    return
                }

                guard let content else {
                    isPresented = false
                    return
                }

                onFileOpen(content)
                isPresented = false
            })
        #endif
    }
}

#if canImport(UIKit)
private struct DocumentPickerView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool

    let onFileOpen: (_ content: Data) -> Void

    init(isPresented: Binding<Bool>, onFileOpen: @escaping (_ content: Data) -> Void) {
        self._isPresented = isPresented
        self.onFileOpen = onFileOpen
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.content])
        documentPicker.delegate = context.coordinator
        documentPicker.allowsMultipleSelection = false
        return documentPicker
    }

    func updateUIViewController(_: UIDocumentPickerViewController, context _: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPickerView

        init(parent: DocumentPickerView) {
            self.parent = parent
        }

        func documentPicker(_: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else {
                logger.error("File not found")
                assertionFailure("File not found")
                parent.isPresented = false
                return
            }

            let content: Data?
            do {
                content = try SecureFileOpener.readData(from: url)
            } catch {
                logger.error(label: "Failed to load file", error: error)
                assertionFailure("Failed to load file")
                parent.isPresented = false
                return
            }

            guard let content else {
                parent.isPresented = false
                return
            }

            parent.onFileOpen(content)
            parent.isPresented = false
        }
    }
}
#endif
