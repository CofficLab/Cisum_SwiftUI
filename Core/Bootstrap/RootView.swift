import MagicKit
import OSLog
import SwiftUI

struct RootView: View, SuperLog, SuperEvent, SuperThread {
    @EnvironmentObject var play: PlayMan
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var data: DataProvider
    
    let emoji = "🌳"
    var dbSynced = DBSynced(Config.getSyncedContainer)

    var body: some View {
        Config.rootBackground
            .ignoresSafeArea()
            .toolbar(content: {
                 ToolbarItem(placement: .navigation) {
                     BtnScene()
                 }

                // MARK: 工具栏

//                if let asset = play.asset {
//                    ToolbarItemGroup(placement: .cancellationAction, content: {
//                        Spacer()
//                        if root.current.isAudioApp {
//                            BtnLike(asset: asset, autoResize: false)
//                        }
//
//                        BtnShowInFinder(url: asset.url, autoResize: false)
//
//                        if root.current.isAudioApp {
//                            BtnDel(assets: [asset], autoResize: false)
//                        }
//                    })
//                }
            })
            .onAppear(perform: onAppear)
    }
}

// MARK: Event Handler

extension RootView {
    func onRootChange() {
        play.stop(reason: "RootView.Root Change")
    }

    func onAppear() {
        let verbose = false
        
        play.onGetChildren = { asset in
            if let children = DiskFile(url: asset.url).children {
                return children.map({ $0.toPlayAsset() })
            }

            return []
        }

        #if os(iOS)
            self.main.async {
                UIApplication.shared.beginReceivingRemoteControlEvents()
            }
        #endif

        self.bg.async {
            if verbose {
                os_log("\(self.t)🐎🐎🐎 执行后台任务")
            }

            //            await self.onAppOpen()
        }

        //        Task {
        //            let uuid = Config.getDeviceId()
        //            let audioCount = disk.getTotal()
        //
        //            await dbSynced.saveDeviceData(uuid: uuid, audioCount: audioCount)
        //        }
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}
