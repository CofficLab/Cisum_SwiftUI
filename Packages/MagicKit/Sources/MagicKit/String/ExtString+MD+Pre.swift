#if DEBUG
import SwiftUI

struct HTMLToMarkdownDemoView: View {
    var body: some View {
        TabView {
            // HTML 转 Markdown 预览
            VStack(alignment: .leading, spacing: 20) {
                Text("HTML 源码：")
                    .font(.headline)
                ScrollView {
                    Text(String.htmlExample)
                        .font(.system(.body, design: .monospaced))
                }
                .frame(height: 200)
                .border(.gray.opacity(0.2))

                Text("转换后的 Markdown：")
                    .font(.headline)
                ScrollView {
                    Text(String.htmlExample.toMarkdown())
                        .font(.system(.body, design: .monospaced))
                }
                .frame(height: 200)
                .border(.gray.opacity(0.2))
            }
            .padding()
            .tabItem {
                Label("基础转换", systemImage: "arrow.triangle.2.circlepath")
            }

            // Base64 图片处理预览
            VStack(alignment: .leading, spacing: 20) {
                Text("包含 Base64 图片的 HTML：")
                    .font(.headline)
                ScrollView {
                    Text(String.htmlExample)
                        .font(.system(.body, design: .monospaced))
                }
                .frame(height: 200)
                .border(.gray.opacity(0.2))

                Text("图片处理说明：")
                    .font(.headline)
                VStack(alignment: .leading, spacing: 10) {
                    Text("1. Base64 图片将被提取并保存为单独的文件")
                    Text("2. 保存路径：/path/to/images/image_0.png")
                    Text("3. Markdown 中使用相对路径引用：![示例图片](images/image_0.png)")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            .padding()
            .tabItem {
                Label("图片处理", systemImage: "photo")
            }
        }
    }
}

// 修改预览
#if DEBUG
#Preview {
    HTMLToMarkdownDemoView()
        .frame(width: 600, height: 500)
}
#endif

#endif
