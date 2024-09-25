import SwiftUI
import MagicKit

struct CoverDirSetting: View {
    var body: some View {
        GroupBox {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("封面图目录").font(.headline)
                    Text(Config.coverDir.absoluteString)
                        .font(.subheadline)
                        .opacity(0.8)
                    Text("根据文件自动生成封面图").font(.footnote)
                }
                Spacer()
                #if os(macOS)
                    Button(action: {
                        FileHelper.openFolder(url: Config.coverDir)
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
}

#Preview {
    CoverDirSetting()
}
