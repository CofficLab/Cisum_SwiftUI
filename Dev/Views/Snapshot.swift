import SwiftUI
import UniformTypeIdentifiers

struct Snapshot<Content>: View where Content: View {
    private let mark: String
    private let content: Content

    var onMessage: (_ message: String) -> Void
    var buttonOnToolbar: Bool = true

    init(mark: String = "", onMessage: @escaping (_ message: String) -> Void, @ViewBuilder content: () -> Content) {
        self.mark = mark
        self.content = content()
        self.onMessage = onMessage
    }

    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                // MARK: 操作栏
                makeActionBar(geo)

                HStack {
                    Spacer()
                    ImageHelper.makeImage(content)
                        .resizable()
                        .scaledToFit()
                        .overlay { ViewHelper.dashedBorder }
                    Spacer()
                }

                Spacer()
            }
            .frame(
                width: getContainerWidth(geo),
                height: getContainerHeight(geo))
        }
    }

    private func getContainerWidth(_ geo: GeometryProxy) -> CGFloat {
        max(geo.size.width, 100)
    }

    private func getContainerHeight(_ geo: GeometryProxy) -> CGFloat {
        max(geo.size.height, 100)
    }

    @MainActor private func makeActionBar(_ geo: GeometryProxy) -> some View {
        HStack {
            Spacer()
            if !mark.isEmpty {
                ViewHelper.makeCard(mark)
            }

            Operator(text: "\(ImageHelper.getViewWidth(content)) X \(ImageHelper.getViewHeigth(content))")
            
            Spacer()

            Button {
                onMessage(ImageHelper.snapshot(content))
            } label: {
                ViewHelper.makeCard("截图")
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .foregroundStyle(.white)
    }
}
