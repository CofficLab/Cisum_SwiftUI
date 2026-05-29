#if DEBUG
import SwiftUI

// MARK: - Preview Container

struct FileTypePreviewContainer: View {
    var body: some View {
        TabView {
            // 媒体文件预览
            MediaFilesPreview()
                .tabItem {
                    Label("媒体", systemImage: .iconPlay)
                }

            // 文档文件预览
            DocumentFilesPreview()
                .tabItem {
                    Label("文档", systemImage: .iconDocument)
                }

            // 开发文件预览
            DeveloperFilesPreview()
                .tabItem {
                    Label("开发", systemImage: .iconCode)
                }

            // 其他文件预览
            OtherFilesPreview()
                .tabItem {
                    Label("其他", systemImage: .iconMore)
                }
        }
    }
}

// MARK: - Media Files Preview

private struct MediaFilesPreview: View {
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 16) {
            Group {
                // 音频文件
                PreviewSection(title: "音频文件") {
                    FileTypeRow(title: "NASA 肯尼迪演讲", url: .sample_web_mp3_kennedy)
                    FileTypeRow(title: "NASA 阿波罗登月", url: .sample_web_mp3_apollo)
                    FileTypeRow(title: "NASA 火箭发射音效", url: .sample_web_wav_launch)
                    FileTypeRow(title: "NASA 火星音效", url: .sample_web_wav_mars)
                }

                // 视频文件
                PreviewSection(title: "视频文件") {
                    FileTypeRow(title: "Big Buck Bunny", url: .sample_web_mp4_bunny)
                    FileTypeRow(title: "Sintel 预告片", url: .sample_web_mp4_sintel)
                    FileTypeRow(title: "Elephants Dream", url: .sample_web_mp4_elephants)
                }

                // 图片文件
                PreviewSection(title: "图片文件") {
                    FileTypeRow(title: "地球 - 蓝色弹珠", url: .sample_web_jpg_earth)
                    FileTypeRow(title: "火星 - 好奇号", url: .sample_web_jpg_mars)
                    FileTypeRow(title: "PNG透明度演示", url: .sample_web_png_transparency)
                    FileTypeRow(title: "RGB渐变演示", url: .sample_web_png_gradient)
                }
            }
        }
        .padding()
    }
}

// MARK: - Document Files Preview

private struct DocumentFilesPreview: View {
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 16) {
            Group {
                // 文档文件
                PreviewSection(title: "Office文档") {
                    FileTypeRow(title: "Word文档", url: URL(fileURLWithPath: "document.docx"))
                    FileTypeRow(title: "Excel表格", url: URL(fileURLWithPath: "spreadsheet.xlsx"))
                    FileTypeRow(title: "PPT演示", url: URL(fileURLWithPath: "presentation.pptx"))
                }

                // 电子书
                PreviewSection(title: "电子书") {
                    FileTypeRow(title: "EPUB电子书", url: URL(fileURLWithPath: "book.epub"))
                    FileTypeRow(title: "PDF文档", url: URL(fileURLWithPath: "document.pdf"))
                    FileTypeRow(title: "Kindle电子书", url: URL(fileURLWithPath: "book.mobi"))
                }

                // 文本文件
                PreviewSection(title: "文本文件") {
                    FileTypeRow(title: "MIT开源协议", url: .sample_web_txt_mit)
                    FileTypeRow(title: "Apache开源协议", url: .sample_web_txt_apache)
                    FileTypeRow(title: "配置文件", url: URL(fileURLWithPath: "config.yml"))
                }
            }
        }
        .padding()
    }
}

// MARK: - Developer Files Preview

private struct DeveloperFilesPreview: View {
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 16) {
            Group {
                // 代码文件
                PreviewSection(title: "代码文件") {
                    FileTypeRow(title: "Swift源文件", url: URL(fileURLWithPath: "main.swift"))
                    FileTypeRow(title: "Python脚本", url: URL(fileURLWithPath: "script.py"))
                    FileTypeRow(title: "Web前端", url: URL(fileURLWithPath: "style.css"))
                }

                // 字体文件
                PreviewSection(title: "字体文件") {
                    FileTypeRow(title: "TrueType字体", url: URL(fileURLWithPath: "font.ttf"))
                    FileTypeRow(title: "OpenType字体", url: URL(fileURLWithPath: "font.otf"))
                    FileTypeRow(title: "Web字体", url: URL(fileURLWithPath: "font.woff2"))
                }
            }
        }
        .padding()
    }
}

// MARK: - Other Files Preview

private struct OtherFilesPreview: View {
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 16) {
            Group {
                // 压缩文件
                PreviewSection(title: "压缩文件") {
                    FileTypeRow(title: "ZIP压缩包", url: URL(fileURLWithPath: "archive.zip"))
                    FileTypeRow(title: "磁盘映像", url: URL(fileURLWithPath: "image.dmg"))
                    FileTypeRow(title: "RAR压缩包", url: URL(fileURLWithPath: "archive.rar"))
                }

                // 网络文件
                PreviewSection(title: "网络文件") {
                    FileTypeRow(title: "网页链接", url: URL(string: "https://example.com")!)
                    FileTypeRow(title: "流媒体", url: .sample_web_stream_basic)
                    FileTypeRow(title: "4K流", url: .sample_web_stream_4k)
                }
            }
        }
        .padding()
    }
}

// MARK: - Helper Views

private struct PreviewSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)

            content
        }
        .padding(.vertical, 8)
    }
}

private struct FileTypeRow: View {
    let title: String
    let url: URL

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            HStack(spacing: 20) {
                // 普通状态
                VStack {
                    url.defaultImage
                        .font(.title)
                    Text("已下载")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Text(url.lastPathComponent)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

#if DEBUG
#Preview("File Types") {
    FileTypePreviewContainer()
}
#endif

#endif
