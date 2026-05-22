import AppKit
import SwiftUI

public struct AppImagePreviewGrid: View {
    let imageDataList: [Data]
    @State private var previewingImage: NSImage?

    public init(imageDataList: [Data]) {
        self.imageDataList = imageDataList
    }

    public var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.adaptive(minimum: 120, maximum: 220), spacing: 8, alignment: .leading),
            ],
            spacing: 8
        ) {
            ForEach(Array(imageDataList.enumerated()), id: \.offset) { _, data in
                if let nsImage = NSImage(data: data) {
                    Button {
                        previewingImage = nsImage
                    } label: {
                        Image(nsImage: nsImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 180, height: 120)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .help("点击预览图片")
                }
            }
        }
        .sheet(
            isPresented: Binding(
                get: { previewingImage != nil },
                set: { isPresented in
                    if !isPresented {
                        previewingImage = nil
                    }
                }
            )
        ) {
            if let previewingImage {
                AppImagePreviewSheet(image: previewingImage)
            }
        }
    }
}

private struct AppImagePreviewSheet: View {
    let image: NSImage
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("关闭") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()

            GeometryReader { geometry in
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                    .padding(20)
            }
        }
        .frame(minWidth: 640, minHeight: 480)
    }
}

#Preview {
    AppImagePreviewGrid(imageDataList: [])
        .padding()
        .frame(width: 400, height: 300)
        .background(Color.gray.opacity(0.15))
}
