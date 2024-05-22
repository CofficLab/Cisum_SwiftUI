import SwiftUI

struct CoverDirSetting: View {
    var body: some View {
        GroupBox {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("封面图目录").font(.headline)
                    Text(AppConfig.coverDir.absoluteString)
                        .font(.subheadline)
                        .opacity(0.8)
                    Text("根据音频文件自动生成封面图").font(.footnote)
                }
                Spacer()
                #if os(macOS)
                    Button(action: {
                        openUrl(AppConfig.coverDir)
                    }, label: {
                        Label(title: {
                            Text("打开")
                        }, icon: {
                            Image(systemName: "doc.viewfinder.fill")
                        })
                    })
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

#Preview {
    CoverDirSetting()
}
