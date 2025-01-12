import MagicKit

import SwiftUI

struct ProTips: View {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var s: StoreProvider

    var supportedFormats: String {
        Config.supportedExtensions.joined(separator: ",")
    }

    var body: some View {
        MagicCard(background: MagicBackground.aurora) {
            VStack {
                VStack(spacing: 20) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.yellow)
                        Text("基础版本最多支持 \(Config.maxAudioCount) 个文件")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                }

                HStack {
                    Text("当前订阅：" + (s.currentSubscription?.displayName ?? "无"))
                }
            }
        }.shadow(radius: 8)
    }
}
