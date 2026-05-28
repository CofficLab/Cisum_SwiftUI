import MagicKit
import SwiftUI

public struct VideoTile: View {
    @Binding private var selection: URL?

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
                    Text(file.getSizeReadable())
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
    }
}
