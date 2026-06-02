#if DEBUG
import SwiftUI

/// 头像视图错误状态预览
public struct AvatarErrorStatesPreview: View {
    public init() {}

    public var body: some View {
        HStack {
            VStack(spacing: 32) {
                VDemoSection(title: "错误状态", icon: "exclamationmark.triangle") {
                    HStack(spacing: 20) {
                        // 无效 URL
                        VStack {
                            URL.sample_invalid_url.makeAvatarView()
                            Text("无效URL")
                                .font(.caption)
                        }

                        // 不存在的文件
                        VStack {
                            URL.sample_nonexistent_file.makeAvatarView()
                            Text("不存在")
                                .font(.caption)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: 500)
        }
        .infinite()
    }
}

// MARK: - Preview

#if DEBUG
#Preview("错误状态") {
    AvatarErrorStatesPreview()
        .frame(width: 500, height: 200)
}
#endif
#endif
