import SwiftUI

public struct VideoGrid: View {
    private let files: [URL]

    @State private var selection: URL?

    public init(files: [URL] = []) {
        self.files = files
    }

    public var body: some View {
        if files.isEmpty {
            ContentUnavailableView("Video", systemImage: "video")
        } else {
            List(files, id: \.self, selection: $selection) { file in
                VideoTile(selection: $selection, file: file)
                    .tag(file)
            }
        }
    }
}
