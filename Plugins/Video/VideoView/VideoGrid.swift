import OSLog
import SwiftData
import SwiftUI

struct VideoGrid: View {
    static var label = "📬 DBTreeView::"

    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var m: MessageProvider
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var p: PluginProvider

    @State var selection: DiskFile?
    @State var collapsed: Bool = false
    @State var icon: String = ""

    var disk: (any SuperStorage)? {
        p.current?.getDisk()
    }

    var body: some View {
        ZStack {
            if let disk = disk {
                List(disk.getRoot().children,
                     id: \.self,
                     children: \.childrenOptional,
                     selection: $selection
                ) { file in
                    VideoTile(selection: $selection, file: file)
                        .tag(file as DiskFile?)
                }
//                    .onAppear {
//                        self.icon = dataManager.isiCloudDisk ? "icloud" : "folder"
//                    }
                    .onChange(of: selection, {
                        if let s = selection, s.isNotFolder() {
                            if playMan.playing {
                                playMan.play(url: s.url)
                            }
                        }
                    })
                //     .onChange(of: playMan.asset?.url, {
                //         if let asset = playMan.asset {
                //             self.selection = DiskFile(url: asset.url)
                //         } else {
                //             self.selection = nil
                //         }
                // }
                
//                )
                
                if app.isDropping || m.flashMessage.isEmpty && disk.getRoot().children.isEmpty {
//                    DBTips()
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
