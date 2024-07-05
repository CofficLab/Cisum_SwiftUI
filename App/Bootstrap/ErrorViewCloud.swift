import SwiftUI

struct ErrorViewCloud: View {
    var body: some View {
        ScrollView {
            VStack {
                Image("PlayingAlbum")
                    .resizable()
                    .scaledToFit()
                    .padding()

                Spacer()

                VStack {
                    Text("需要登录 iCloud")
                        .font(.title)
                        .padding(.bottom, 10)

                    VStack {
                        Button("打开系统设置登录iCloud") {
                            openSystemSettings()
                        }.padding()
                    }

                    Spacer()

                    #if os(macOS)
                        Button("退出") {
                            NSApplication.shared.terminate(self)
                        }.controlSize(.extraLarge)

                        Spacer()
                    #else
                        Button("关闭 APP") {
                            quitApp()
                        }.padding()
                    #endif

                    debugView
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
            Text(key)
            Spacer()
            Text(value)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }).padding(5)
    }

    private func isFileExist(_ url: URL) -> String {
        FileManager.default.fileExists(atPath: url.path) ? "是" : "否"
    }

    private func isDirExist(_ url: URL) -> String {
        var isDir: ObjCBool = true
        return FileManager.default.fileExists(atPath: url.path(), isDirectory: &isDir) ? "是" : "否"
    }

    private func openSystemSettings() {
        #if os(iOS)
            guard let url = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        #elseif os(macOS)
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference") {
                NSWorkspace.shared.open(url)
            }
        #endif
    }

    private func quitApp() {
        #if os(iOS)
        let selector = NSSelectorFromString("terminate")
        if let method = UIApplication.shared.method(for: selector) {
            UIApplication.shared.perform(selector, with: nil)
        }
        #elseif os(macOS)
        NSApplication.shared.terminate(self)
        #endif
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
