import SwiftUI

/// 内容区无可用 Tab 时的占位视图。
struct EmptyTabView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "music.note.list")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(.tertiary)
            Text("No content available in the current scene", bundle: .module)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
