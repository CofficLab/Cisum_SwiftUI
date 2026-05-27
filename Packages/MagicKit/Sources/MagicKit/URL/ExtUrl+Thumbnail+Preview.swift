#if DEBUG
    import AVFoundation

    import SwiftUI

    struct ThumbnailPreview: View {
        @State private var audioThumbnail: Image?
        @State private var videoThumbnail: Image?
        @State private var isLoading = false
        @State private var errorMessage: String?
        @State private var useDefaultIcon: Bool = true

        // 测试用的音频和视频文件 URL
        private let audioURL = URL.sample_temp_mp3
        private let videoURL = URL.sample_temp_mp4

        var body: some View {
            VStack(spacing: 20) {
                // 音频缩略图展示
                Group {
                    Text("音频文件缩略图")
                        .font(.headline)

                    if let audioThumbnail {
                        audioThumbnail
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                    } else {
                        Text("无封面")
                            .frame(width: 200, height: 200)
                            .background(Color.gray.opacity(0.2))
                    }

                    HStack(spacing: 20) {
                        Button("加载音频封面") {
                            loadAudioThumbnail()
                        }

                        Button("写入测试封面") {
                            writeSampleCover()
                        }
                    }
                }

                // 视频缩略图展示
                Group {
                    Text("视频文件缩略图")
                        .font(.headline)

                    if let videoThumbnail {
                        videoThumbnail
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                    } else {
                        Text("无封面")
                            .frame(width: 200, height: 200)
                            .background(Color.gray.opacity(0.2))
                    }

                    Toggle("使用默认图标", isOn: $useDefaultIcon)
                        .toggleStyle(.switch)
                        .frame(maxWidth: 240)

                    Button("加载视频封面") {
                        loadVideoThumbnail()
                    }
                }

                if isLoading {
                    ProgressView()
                }

                if let errorMessage {
                    HStack {
                        Text(errorMessage)
                            .foregroundColor(.red)

                        Button(action: {
                            errorMessage.copy()
                        }) {
                            Image(systemName: "doc.on.doc")
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(.plain)
                        .help("复制错误信息")
                    }
                }
            }
            .padding()
            .inScrollView()
            .frame(height: 700)
        }

        private func loadAudioThumbnail() {
            let url = audioURL

            isLoading = true
            errorMessage = nil

            Task {
                do {
                    if let thumbnail = try await url.coverFromMetadata(size: CGSize(width: 200, height: 200)) {
                        await MainActor.run {
                            audioThumbnail = thumbnail
                        }
                    }
                } catch {
                    await MainActor.run {
                        errorMessage = "加载音频封面失败: \(error.localizedDescription)"
                    }
                }

                await MainActor.run {
                    isLoading = false
                }
            }
        }

        private func loadVideoThumbnail() {
            let url = videoURL

            isLoading = true
            errorMessage = nil

            Task {
                do {
                    if let result = try await url.thumbnail(size: CGSize(width: 200, height: 200), useDefaultIcon: useDefaultIcon, verbose: true, reason: "loadVideoThumbnail"),
                       let thumbnail = result.toSwiftUIImage() {
                        await MainActor.run {
                            videoThumbnail = thumbnail
                        }
                    }
                } catch {
                    await MainActor.run {
                        errorMessage = "加载视频封面失败: \(error.localizedDescription)"
                    }
                }

                await MainActor.run {
                    isLoading = false
                }
            }
        }

        private func writeSampleCover() {
            let url = audioURL

            isLoading = true
            errorMessage = nil

            Task {
                do {
                    // 创建一个示例图片
                    let image = Image.PlatformImage.sampleImage(size: CGSize(width: 500, height: 500))
                    // 获取图片数据
                    #if os(macOS)
                        guard let imageData = image.tiffRepresentation else {
                            throw NSError(domain: "MagicKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法获取图片数据"])
                        }
                    #else
                        guard let imageData = image.pngData() else {
                            throw NSError(domain: "MagicKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法获取图片数据"])
                        }
                    #endif

                    try await url.writeCoverToMediaFile(imageData: imageData, verbose: true)
                    // 重新加载显示新封面
                    loadAudioThumbnail()
                } catch {
                    await MainActor.run {
                        errorMessage = "写入封面失败: \(error.localizedDescription)"
                    }
                }

                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }

    #if DEBUG
    #Preview {
        ThumbnailPreview()
    }
    #endif

#endif
