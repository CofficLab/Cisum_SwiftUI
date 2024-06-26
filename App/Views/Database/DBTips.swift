import SwiftData
import SwiftUI

struct DBTips: View {
  @EnvironmentObject var app: AppManager
  @EnvironmentObject var dataManager: DataManager

  @Query(Audio.descriptorAll, animation: .default) var audios: [Audio]

  var supportedFormats: String {
    Config.supportedExtensions.joined(separator: ",")
  }

  var showTips: Bool {
    if app.isDropping {
      return true
    }

    return app.flashMessage.isEmpty && audios.count == 0
  }

  var body: some View {
    if showTips {
      CardView(background: BackgroundView.type3) {
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
                  FileHelper.openFolder(url: dataManager.disk.root)
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
}

#Preview {
  DBTips()
    .frame(width: 300, height: 300)
    .background(BackgroundView.type1)
}

#Preview {
  BootView {
    DBLayout()
  }.modelContainer(Config.getContainer)
}
