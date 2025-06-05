import MagicCore

import SwiftUI

struct AudioDBTips: View {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var audioManager: AudioProvider

    var supportedFormats: String {
        Config.supportedExtensions.joined(separator: ",")
    }

    var body: some View {
        MagicCard(background: MagicBackground.mountainStream) {
            VStack {
                VStack(spacing: 20) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.yellow)
                        Text(Config.isDesktop ? "将音乐文件拖到这里可添加" : "仓库为空")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                    Text("支持的格式：\(supportedFormats)")
                        .font(.subheadline)
                        .foregroundStyle(.white)

                    #if os(macOS)
                        HStack {
                            Text("或").foregroundStyle(.white)
                        }

                        Button(
                            action: {
                                audioManager.disk.openFolder()
                            },
                            label: {
                                Label(
                                    title: {
                                        Text("打开仓库目录并放入文件")
                                    },
                                    icon: {
                                        Image(systemName: "doc.viewfinder.fill")
                                    })
                            })
                    #endif

                    if Config.isNotDesktop {
                        BtnAdd().buttonStyle(.bordered).foregroundStyle(.white)
                    }
                }
            }
        }.shadow(radius: 8)
    }
}

#Preview {
    AudioDBTips()
        .frame(width: 300, height: 300)
}
