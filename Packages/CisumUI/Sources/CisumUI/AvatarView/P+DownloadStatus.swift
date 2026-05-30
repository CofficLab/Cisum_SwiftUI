#if DEBUG
import SwiftUI

/// 头像视图下载状态预览
public struct AvatarDownloadStatusPreview: View {
    @State private var icloudFiles: [URL] = []
    @State private var isCreatingFiles = false
    @State private var errorMessage: String?

    public init() {}

    public var body: some View {
        HStack {
            VStack(spacing: 32) {
                // iCloud 文件
                AvatarPreviewHelpers.demoSection("iCloud 文件") {
                    VStack(spacing: 16) {
                        if isCreatingFiles {
                            ProgressView("正在准备 iCloud 示例文件...")
                        } else if let error = errorMessage {
                            VStack(spacing: 8) {
                                Text("创建失败")
                                    .foregroundStyle(.red)
                                Text(error)
                                    .font(.caption)
                                    .multilineTextAlignment(.center)

                                Button("重试") {
                                    createICloudFiles()
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        } else if icloudFiles.isEmpty {
                            Button("创建 iCloud 示例文件") {
                                createICloudFiles()
                            }
                            .buttonStyle(.borderedProminent)
                        } else {
                            HStack(spacing: 20) {
                                ForEach(icloudFiles, id: \.absoluteString) { url in
                                    VStack {
                                        url.makeAvatarView()
                                            .magicSize(48)
                                            .magicDownloadMonitor(true)
                                        Text(url.lastPathComponent)
                                            .font(.caption)
                                    }
                                }
                            }

                            Button("重置") {
                                icloudFiles = []
                                errorMessage = nil
                            }
                            .buttonStyle(.borderless)
                            .foregroundStyle(.secondary)
                        }
                    }
                }

                // 下载监控
                VDemoSection(title: "下载监控设置", icon: "eye") {
                    HStack(spacing: 20) {
                        // 启用监控
                        VStack {
                            URL.sample_web_jpg_earth.makeAvatarView()
                                .magicDownloadMonitor(true)
                            Text("启用监控")
                                .font(.caption)
                        }

                        // 禁用监控
                        VStack {
                            URL.sample_web_jpg_earth.makeAvatarView()
                                .magicDownloadMonitor(false)
                            Text("禁用监控")
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

    private func createICloudFiles() {
        isCreatingFiles = true
        errorMessage = nil

        URL.createICloudSamples { files, error in
            isCreatingFiles = false
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                icloudFiles = files
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("下载状态") {
    AvatarDownloadStatusPreview()
        .frame(width: 500, height: 500)
}
#endif
#endif
