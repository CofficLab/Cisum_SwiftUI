#if DEBUG
    import SwiftUI

    /// 头像视图基础样式预览
    public struct AvatarBasicPreview: View {
        public init() {}

        public var body: some View {
            VStack(spacing: 32) {
                // 默认样式
                AvatarPreviewHelpers.demoSection("默认样式") {
                    HStack(spacing: 20) {
                        URL.sample_temp_txt.makeAvatarView()

                        URL.sample_temp_html.makeAvatarView()

                        URL.sample_temp_pdf.makeAvatarView()
                    }
                }

                // 自定义背景色
                AvatarPreviewHelpers.demoSection("自定义背景色") {
                    HStack(spacing: 20) {
                        URL.sample_temp_pdf.makeAvatarView()
                            .magicBackground(.red.opacity(0.1))

                        URL.sample_temp_pdf.makeAvatarView()
                            .magicBackground(.green.opacity(0.1))

                        URL.sample_temp_pdf.makeAvatarView()
                            .magicBackground(.purple.opacity(0.1))
                    }
                }

                // 不同尺寸
                AvatarPreviewHelpers.demoSection("不同尺寸") {
                    HStack(spacing: 20) {
                        URL.sample_temp_pdf.makeAvatarView()
                            .magicSize(32)

                        URL.sample_temp_pdf.makeAvatarView()
                            .magicSize(48)

                        URL.sample_temp_pdf.makeAvatarView()
                            .magicSize(64)
                    }
                }

                // 不同形状
                AvatarPreviewHelpers.demoSection("不同形状") {
                    HStack(spacing: 20) {
                        URL.sample_temp_pdf
                            .makeAvatarView()
                            .magicAvatarShape(.circle)

                        URL.sample_temp_pdf
                            .makeAvatarView()
                            .magicAvatarShape(.roundedRectangle(cornerRadius: 8))

                        URL.sample_temp_pdf
                            .makeAvatarView()
                            .magicAvatarShape(.rectangle)
                    }
                }
            }
            .padding()
            .infinite()
        }
    }

    // MARK: - Preview

    #if DEBUG
    #Preview("基础样式") {
        AvatarBasicPreview()
            .frame(width: 500, height: 600)
    }
    #endif
#endif
