#if DEBUG
    import SwiftUI

    /// 头像视图文件类型预览
    public struct AvatarFileTypesPreview: View {
        public init() {}

        public var body: some View {
            HStack {
                VStack(spacing: 32) {
                    AvatarPreviewHelpers.demoSection("不同文件类型") {
                        HStack(spacing: 20) {
                            // 图片文件
                            VStack {
                                URL.sample_temp_jpg.makeAvatarView()
                                Text("图片")
                                    .font(.caption)
                            }

                            // 音频文件
                            VStack {
                                URL.sample_web_mp3_kennedy.makeAvatarView()
                                Text("音频")
                                    .font(.caption)
                            }

                            // 视频文件
                            VStack {
                                URL.sample_web_mp4_bunny.makeAvatarView()
                                Text("视频")
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
    #Preview("文件类型") {
        AvatarFileTypesPreview()
            .frame(width: 500, height: 300)
    }
    #endif
#endif
