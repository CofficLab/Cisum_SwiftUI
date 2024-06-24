import SwiftUI

struct DirSetting: View {
    @EnvironmentObject var diskManager: DiskManager
    
    var body: some View {
        GroupBox {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("仓库目录").font(.headline)
                    if diskManager.isiCloudDisk {
                        Text("是 iCloud 云盘目录，会保持同步").font(.footnote)
                    } else {
                        Text("是本地目录，不会同步").font(.footnote)
                    }
                    Text("本目录的文件可随意修改").font(.footnote)
                }
                Spacer()
                #if os(macOS)
                    Button(action: {
                        openUrl(diskManager.disk.root)
                    }, label: {
                        Label(title: {
                            Text("打开")
                        }, icon: {
                            Image(systemName: "doc.viewfinder.fill")
                        })
                    })
                    .labelStyle(.iconOnly)
                #endif
            }.padding(10)
        }.background(BackgroundView.type1.opacity(0.1))
    }

    private func openUrl(_ url: URL?) {
        #if os(macOS)
            guard let dir = url else {
                // 显示错误提示
                let errorAlert = NSAlert()
                errorAlert.messageText = "打开目录出错"
                errorAlert.informativeText = "目录不存在"
                errorAlert.alertStyle = .critical
                errorAlert.addButton(withTitle: "好的")
                errorAlert.runModal()

                return
            }

            NSWorkspace.shared.open(dir)
        #endif
    }
}

#Preview("Setting") {
    RootView {
        SettingView()
            .background(.background)
    }.modelContainer(Config.getContainer)
        .frame(height: 1200)
}

#Preview {
    DirSetting()
}
