import MagicKit
import MagicUI
import SwiftUI

struct DropTips: View {
    @EnvironmentObject var app: AppProvider

    var supportedFormats: String {
        Config.supportedExtensions.joined(separator: ",")
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(.yellow)
                Text(Config.isDesktop ? "将音乐文件拖到这里可添加" : "仓库为空")
                    .font(.title3)
            }
            Text("支持的格式：\(supportedFormats)")
                .font(.subheadline)

            if Config.isNotDesktop {
                BtnAdd().buttonStyle(.bordered).foregroundStyle(.white)
            }
        }
        .inCard()
    }
}
