import SwiftUI

/// 当前曲目标题，对应旧版 TitleView。
struct TitleView: View {
    @ObservedObject var model: MockPlayerModel

    var body: some View {
        VStack(spacing: 6) {
            Text(model.title)
                .font(.system(size: 25, weight: .medium))
                .lineLimit(2)
                .multilineTextAlignment(.center)
            Text(model.artist)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
    }
}
