import SwiftUI

struct DBTips: View {
    @EnvironmentObject var appManager: AppManager
    
    var supportedFormats: String {
        AppConfig.supportedExtensions.joined(separator: ",")
    }

    var body: some View {
        CardView(background: BackgroundView.type3) {
            VStack {
                VStack(spacing: 20) {
                    HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundStyle(.yellow)
                        Text(AppConfig.isDesktop ? "将音乐文件拖到这里可添加" : "仓库为空")
                                .font(.title3)
                                .foregroundStyle(.white)
                    }
                    Text("支持的格式：\(supportedFormats)")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                    
                    if AppConfig.isNotDesktop {
                        BtnAdd().buttonStyle(.bordered).foregroundStyle(.white)
                    }
                }
            }
        }
    }
}

#Preview {
    DBTips()
        .frame(width: 300, height: 300)
        .background(BackgroundView.type1)
}

#Preview {
    RootView {
        DBView()
    }.modelContainer(AppConfig.getContainer())
}
