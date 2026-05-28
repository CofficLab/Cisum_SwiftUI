import SwiftUI

public struct VideoDB: View {
    private let files: [URL]

    public init(files: [URL] = []) {
        self.files = files
    }

    public var body: some View {
        VideoGrid(files: files)
            .frame(maxHeight: .infinity)
    }
}
