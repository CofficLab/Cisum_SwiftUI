import SwiftUI

/// 内容区未注入时的占位视图。
struct ContentPlaceholderView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "music.note.list")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("暂无内容")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
