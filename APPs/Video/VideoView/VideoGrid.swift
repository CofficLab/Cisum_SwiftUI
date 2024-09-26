import OSLog
import SwiftData
import SwiftUI

struct VideoGrid: View {
    static var label = "📬 DBTreeView::"

    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var dataManager: DataProvider
    @EnvironmentObject var playMan: PlayMan

    @State var selection: DiskFile?
    @State var collapsed: Bool = false
    @State var icon: String = ""

    var disk = VideoApp().getDisk()

    var body: some View {
        ZStack {
            if let disk = disk {
                List(disk.getRoot().children ?? [],
                     id: \.self,
                     children: \.children,
                     selection: $selection
                ) { file in
                    SongTile(file.toPlayAsset())
                        .tag(file as DiskFile?)
                }
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
                
                if app.isDropping || app.flashMessage.isEmpty && disk.getRoot().getChildren()?.isEmpty ?? true {
                    DBTips()
                }
            }
            
        }
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
