import MagicKit
import SwiftUI

struct VideoFileSizeLoadPolicy {
    static func shouldApplySize(currentFile: URL, requestedFile: URL) -> Bool {
        currentFile == requestedFile
    }
}

public struct VideoTile: View {
    @Binding private var selection: URL?
    @State private var fileSize: String?

    private let file: URL

    public init(selection: Binding<URL?>, file: URL) {
        _selection = selection
        self.file = file
    }

    public var body: some View {
        HStack {
            Image(systemName: "video")
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(file.title)

                if file.isNotFolder {
                    Text(fileSize ?? String(localized: "Calculating...", table: "Video", bundle: .module))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            file.makeOpenButton()
                .labelStyle(.iconOnly)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selection = file
        }
        .task(id: file, priority: .background) {
            await loadFileSize()
        }
    }

    private func loadFileSize() async {
        fileSize = nil

        guard file.isNotFolder else { return }

        let requestedFile = file
        let size = await Self.readableFileSize(for: requestedFile)

        guard !Task.isCancelled,
              VideoFileSizeLoadPolicy.shouldApplySize(currentFile: file, requestedFile: requestedFile) else {
            return
        }

        fileSize = size
    }

    nonisolated static func readableFileSize(for file: URL) async -> String {
        await Task.detached(priority: .utility) {
            file.getSizeReadable()
        }.value
    }
}
