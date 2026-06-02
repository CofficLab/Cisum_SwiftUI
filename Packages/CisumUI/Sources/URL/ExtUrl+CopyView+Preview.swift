#if DEBUG

import SwiftUI

/// 文件复制视图的预览示例
///
/// 包含以下预览类别：
/// - 基础样式：展示默认样式和自定义背景、阴影效果
/// - 形状：展示不同的形状选项（圆角矩形、矩形、胶囊形状）
/// - 下载：展示不同类型文件的复制效果
/// - 错误处理：展示各种错误情况的处理
struct CopyViewPreviewContainer: View {
    var body: some View {
        TabView {
            // 基础样式预览
            BasicStylesPreview()
                .tabItem {
                    Label("基础样式", systemImage: .iconPaintbrush)
                }

            // 形状预览
            ShapesPreview()
                .tabItem {
                    Label("形状", systemImage: .iconSquareOnCircle)
                }

            // 下载预览
            DownloadPreview()
                .tabItem {
                    Label("下载", systemImage: .iconICloudDownloadAlt)
                }

            // 错误处理预览
            ErrorHandlingPreview()
                .tabItem {
                    Label("错误处理", systemImage: .iconWarning)
                }
        }
    }
}

/// 基础样式预览
///
/// 展示：
/// - 默认样式
/// - 自定义背景色
/// - 自定义阴影效果
private struct BasicStylesPreview: View {
    @State private var error: Error?

    var body: some View {
        VStack(spacing: 20) {
            Group {
                // 默认样式
                Text("默认样式")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                URL.sample_temp_txt
                    .copyView(destination: .documentsDirectory.appendingPathComponent("copy"), verbose: false)
                    .withBackground()
            }

            Group {
                // 自定义背景色
                Text("自定义背景色")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                URL.sample_web_jpg_moon
                    .copyView(destination: .documentsDirectory.appendingPathComponent("random.jpg"), verbose: false)
                    .withBackground(.blue.opacity(0.1))
            }

            Group {
                // 自定义阴影
                Text("自定义阴影")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                URL.sample_web_txt_bsd
                    .copyView(destination: .documentsDirectory.appendingPathComponent("download.bin"), verbose: false)
                    .withBackground(.green.opacity(0.1))
                    .withShadow(radius: 8)
            }

            Group {
                // 手动复制
                Text("手动复制")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                URL.sample_web_txt_bsd
                    .copyView(destination: .documentsDirectory.appendingPathComponent("manual.txt"), verbose: false)
                    .withBackground(.pink.opacity(0.1))
                    .withAutoStart(false)
            }
        }
        .padding()
    }
}

/// 形状样式预览
///
/// 展示：
/// - 圆角矩形（默认）
/// - 矩形
/// - 胶囊形状
private struct ShapesPreview: View {
    @State private var error: Error?

    var body: some View {
        VStack(spacing: 20) {
            Group {
                // 圆角矩形（默认）
                Text("圆角矩形（默认）")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                URL.sample_web_jpg_earth
                    .copyView(destination: .documentsDirectory, verbose: false)
                    .withBackground(.mint.opacity(0.1))
            }

            Group {
                // 矩形
                Text("矩形")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                URL.sample_web_jpg_earth
                    .copyView(destination: .documentsDirectory, verbose: false)
                    .withShape(.rectangle)
                    .withBackground(.orange.opacity(0.1))
            }

            Group {
                // 胶囊形状
                Text("胶囊形状")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                URL.sample_web_jpg_earth
                    .copyView(destination: .documentsDirectory, verbose: false)
                    .withShape(.capsule)
                    .withBackground(.purple.opacity(0.1))
            }
        }
        .padding()
    }
}

/// 文件下载预览
///
/// 展示不同类型文件的复制效果：
/// - 音频文件
/// - 视频文件
/// - 图片文件
/// - PDF文件
private struct DownloadPreview: View {
    @State private var error: Error?

    var body: some View {
        VStack(spacing: 20) {
            Group {
                // 音频文件
                Text("音频文件")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                URL.sample_web_mp3_kennedy
                    .copyView(destination: .documentsDirectory, verbose: false)
                    .withBackground(.blue.opacity(0.1))
            }

            Group {
                // 视频文件
                Text("视频文件")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                URL.sample_web_mp4_bunny
                    .copyView(destination: .documentsDirectory, verbose: false)
                    .withBackground(.green.opacity(0.1))
            }

            Group {
                // 图片文件
                Text("图片文件")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                URL.sample_web_jpg_earth
                    .copyView(destination: .documentsDirectory, verbose: false)
                    .withBackground(.purple.opacity(0.1))
            }

            Group {
                // PDF文件
                Text("PDF文件")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                URL.sample_web_pdf_swift_guide
                    .copyView(destination: .documentsDirectory, verbose: false)
                    .withBackground(.orange.opacity(0.1))
            }
        }
        .padding()
    }
}

/// 错误处理预览
///
/// 展示各种错误情况：
/// - 文件不存在
/// - 权限错误
/// - 目标位置已存在
private struct ErrorHandlingPreview: View {
    @State private var error: Error?

    var body: some View {
        VStack(spacing: 20) {
            Group {
                // 文件不存在
                Text("文件不存在")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                URL(fileURLWithPath: "/nonexistent/path.txt")
                    .copyView(destination: .documentsDirectory, verbose: false)
                    .withBackground(.red.opacity(0.1))
            }

            Group {
                // 权限错误
                Text("权限错误")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                URL(fileURLWithPath: "/System/file.txt")
                    .copyView(destination: .documentsDirectory, verbose: false)
                    .withBackground(.orange.opacity(0.1))
            }

            Group {
                // 目标位置已存在
                Text("目标位置已存在")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                URL.sample_web_txt_mit
                    .copyView(destination: URL.sample_web_txt_mit, verbose: false)
                    .withBackground(.yellow.opacity(0.1))
            }
        }
        .padding()
    }
}

#if DEBUG
#Preview("Copy View") {
    CopyViewPreviewContainer()
}
#endif

#endif
