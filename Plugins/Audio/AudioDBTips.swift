import MagicKit
import SwiftUI

struct AudioDBTips: View {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var data: DataProvider
    @EnvironmentObject var s: StoreProvider

    var supportedFormats: String {
        Config.supportedExtensions.joined(separator: ",")
    }

    var body: some View {
        CardView(background: BackgroundView.type2A) {
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
//                                FileHelper.openFolder(url: data.disk.root)
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

                    HStack {
                        Text("当前订阅：" + (s.currentSubscription?.displayName ?? "无"))
                    }
                }
            }
        }
        .shadow(radius: 8)
        .background(.background)
    }
}

#Preview {
    DBTips()
        .frame(width: 300, height: 300)
        .background(BackgroundView.type1)
}
