import CloudKit
import MagicKit
import OSLog
import SwiftUI

struct ErrorViewCloud: View, SuperLog, SuperThread {
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
                    Text(error.localizedDescription)
                        .font(.title)
                        .padding(.bottom, 10)

                    VStack {
                        Button("打开系统设置登录iCloud") {
                            openSystemSettings()
                        }.padding()

                        Text("请打开访达检查 iCloud 云盘是否可用")
                    }

                    Spacer()

                    debugView
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background.opacity(0.8))
    }

    var debugView: some View {
        VStack(spacing: 10) {
            Section(content: {
                GroupBox {
                    makeKeyValueItem(key: "使用iCloud", value: Config.iCloudEnabled ? "是" : "否")
                    Divider()
                    makeKeyValueItem(key: "启用iCloud云盘", value: iCloudHelper.iCloudDiskEnabled() ? "是" : "否")
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
            if let url = URL(string: "App-Prefs:root=CASTLE") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    // 如果无法打开设置首页，回退到打开应用自身的设置
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                    }
                }
            }
        #elseif os(macOS)
            if let url = URL(string: "x-apple.systempreferences:") {
                NSWorkspace.shared.open(url)
            }
        #elseif os(visionOS)
            if let url = URL(string: "App-Prefs:root") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    // 如果无法打开设置首页，回退到打开应用自身的设置
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                    }
                }
            }
        #endif
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
