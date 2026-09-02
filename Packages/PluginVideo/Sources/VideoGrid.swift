import SwiftUI

public struct VideoGrid: View {
    private let files: [URL]

    @State private var selection: URL?

    public init(files: [URL] = []) {
        self.files = files
    }

    public var body: some View {
        if files.isEmpty {
            ContentUnavailableView {
                Label {
                    Text(Self.emptyStateTitle)
                } icon: {
                    Image(systemName: "video")
                }
            } description: {
                Text(Self.emptyStateDescription)
            }
        } else {
            List(files, id: \.self, selection: $selection) { file in
                VideoTile(selection: $selection, file: file)
                    .tag(file)
            }
        }
    }
}

extension VideoGrid {
    nonisolated static var emptyStateTitleKey: String { "Video" }
    nonisolated static var emptyStateDescriptionKey: String { "No video files available" }

    private static var emptyStateTitle: String {
        String(localized: String.LocalizationValue(emptyStateTitleKey), bundle: .module)
    }

    private static var emptyStateDescription: String {
        String(localized: String.LocalizationValue(emptyStateDescriptionKey), bundle: .module)
    }
}
