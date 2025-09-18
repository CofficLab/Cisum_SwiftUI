import MagicCore
import MagicBackground
import SwiftUI

struct DropTips: View {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var s: StoreProvider

    var supportedFormats: String {
        Config.supportedExtensions.joined(separator: ",")
    }

    var body: some View {
        MagicCard(background: MagicBackground.aurora.background(.background)) {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.yellow)
                    Text(Config.isDesktop ? "将音乐文件拖到这里可添加" : "仓库为空")
                        .font(.title3)
                }
                Text("支持的格式：\(supportedFormats)")
                    .font(.subheadline)
                
//                    #if os(macOS)
//                        HStack {
//                            Text("或").foregroundStyle(.white)
//                        }
//
//                        Button(
//                            action: {
                ////                                FileHelper.openFolder(url: data.disk.root)
//                            },
//                            label: {
//                                Label(
//                                    title: {
//                                        Text("打开仓库目录并放入文件")
//                                    },
//                                    icon: {
//                                        Image(systemName: "doc.viewfinder.fill")
//                                    })
//                            })
//                    #endif

                if Config.isNotDesktop {
                    BtnAdd().buttonStyle(.bordered).foregroundStyle(.white)
                }
            }
        }
    }
}
