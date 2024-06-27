import SwiftUI

struct FatalErrorView: View {
    var error: Error
    
    var body: some View {
        ScrollView {
            VStack {
                Image("PlayingAlbum")
                    .resizable()
                    .scaledToFit()
                    .padding()

                Spacer()

                VStack {
                    Text("遇到问题无法继续运行")
                        .font(.title)
                        .padding(.bottom, 10)

                    Text("\(error.localizedDescription)")
                        .font(.subheadline)
                        .padding(.bottom, 10)

                    Text(String(describing: type(of: error)))
                        .padding(.bottom, 10)

                    Text(String(describing: error))

                    Spacer()
                    
                    debugView

                    #if os(macOS)
                        Button("退出") {
                            NSApplication.shared.terminate(self)
                        }.controlSize(.extraLarge)

                        Spacer()
                    #endif
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BackgroundView.forest)
    }
    
    var debugView: some View {
        VStack(spacing: 10) {
            Section(content: {
                GroupBox {
                    makeKeyValueItem(key: "使用 iCloud", value: Config.iCloudEnabled ? "是" : "否")
                    Divider()
                    makeKeyValueItem(key: "登录 iCloud", value: iCloudHelper.iCloudEnabled() ? "是" : "否")
                }
            }, header: { makeTitle("iCloud") })
        }.padding(20)
    }

    private func makeTitle(_ title: String) -> some View {
        HStack {
            Text(title).font(.headline).padding(.leading, 10)
            Spacer()
        }
    }

    private func makeKeyValueItem(key: String, value: String) -> some View {
        HStack(content: {
            VStack(alignment: .leading, spacing: 5) {
                Text(key)
                Text(value)
                    .font(.footnote)
                    .opacity(0.8)
            }
            Spacer()
        }).padding(5)
    }
    
    private func isFileExist(_ url: URL) -> String {
        FileManager.default.fileExists(atPath: url.path) ? "是" : "否"
    }
    
    private func isDirExist(_ url: URL) -> String {
        var isDir: ObjCBool = true
        return FileManager.default.fileExists(atPath: url.path(), isDirectory: &isDir) ? "是" : "否"
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
