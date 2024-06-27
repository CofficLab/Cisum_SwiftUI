import OSLog
import SwiftData
import SwiftUI

struct DBViewTree: View {
    static var label = "📬 DBTreeView::"

    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var playMan: PlayMan

    @State var selection: DiskFile?
    @State var collapsed: Bool = false
    @State var icon: String = ""

    var disk: Disk { dataManager.disk }
    var root: URL { disk.root }
    var rootDiskFile: DiskFile { disk.getRoot() }

    var body: some View {
        listView
            .onAppear {
                self.icon = dataManager.isiCloudDisk ? "icloud" : "folder"
            }
            .onChange(of: selection, {
                if let s = selection, s.isNotFolder() {
                    if playMan.isPlaying {
                        playMan.play(s.toPlayAsset(), reason: "点击了")
                    } else {
                        playMan.prepare(s.toPlayAsset())
                    }
                }
            })
            .onChange(of: playMan.asset?.url, {
                if let asset = playMan.asset {
                    self.selection = DiskFile(url: asset.url)
                } else {
                    self.selection = nil
                }
            })
    }

    // 使用原生的List，所有平台都适配
    var listView: some View {
        List(rootDiskFile.getChildren() ?? [],
             id: \.self,
             children: \.children,
             selection: $selection
        ) { file in
            HStack {
                file.image
                Text(file.title)
            }
                .tag(file as DiskFile?)
                .contextMenu(ContextMenu(menuItems: {
                    BtnPlay(asset: file.toPlayAsset(), autoResize: false)
                    Divider()
                    BtnDownload(asset: file.toPlayAsset())
                    BtnEvict(asset: file.toPlayAsset())
                    if Config.isDesktop {
                        BtnShowInFinder(url: file.url, autoResize: false)
                    }
                    Divider()
                    BtnDel(assets: [file.toPlayAsset()], autoResize: false)
                }))
        }
    }

    // 使用自定义的组件，只适配了macOS
    var tileView: some View {
        DBTree(
            selection: $selection,
            icon: $icon,
            collapsed: collapsed,
            file: disk.getRoot()
        )
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 820)
}

#Preview {
    LayoutView(width: 400, height: 800)
        .frame(height: 820)
}
