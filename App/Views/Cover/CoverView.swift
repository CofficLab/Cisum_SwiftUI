import OSLog
import SwiftUI

struct CoverView: View {
    @EnvironmentObject var app: AppManager
    @EnvironmentObject var data: DataManager
    @EnvironmentObject var playMan: PlayMan
    
    enum Role {
        case Icon
        case Hero
    }
    
    var asset: PlayAsset
    var role: Role = .Icon
    
    init(_ asset: PlayAsset, role: Role = .Icon) {
        self.asset = asset
        self.role = role
    }

    var body: some View {
        ZStack {
            if role == .Icon {
                PictureView(asset, role: role)
            } else {
                if playMan.isVideoWorker {
                    VideoView(asset)
                } else {
                    PictureView(asset, role: role)
                }
            }
            
        }
    }
}

#Preview("APP") {
    AppPreview()
        .frame(height: 800)
}

#Preview("ProgressView") {
    PictureView.makeProgressView()
        .frame(width: 300, height: 300)
        .background(BackgroundView.type2)
}

#Preview("List") {
    List {
        HStack {
            PictureView.makeProgressView()
            Text("1")
        }.frame(
            width: Config.isDesktop ? 36 : 36,
            height: Config.isDesktop ? 36 : 36
        ).background(.red.opacity(0.2))
        HStack {
            PictureView.makeProgressView().frame(
                width: Config.isDesktop ? 48 : 36,
                height: Config.isDesktop ? 36 : 36
            )
            Text("2")
        }.background(.blue.opacity(0.2))
    }.background(BackgroundView.type4)
}
