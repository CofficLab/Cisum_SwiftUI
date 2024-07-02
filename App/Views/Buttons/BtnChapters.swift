import OSLog
import SwiftData
import SwiftUI

struct BtnChapters: View {
    @EnvironmentObject var app: AppManager
    @EnvironmentObject var data: DataManager
    @EnvironmentObject var playMan: PlayMan
    
    @State var isPresented = false
    @State var selection: DiskFile?
    
    var asset: PlayAsset? { playMan.asset }
    var items: [DiskFile] {
        guard let asset = asset else {
            return []
        }
        
        return DiskFile(url: asset.url.deletingLastPathComponent()).getChildren() ?? []
    }

    var body: some View {
        ControlButton(
            title: "章节",
            image: "book",
            dynamicSize: true,
            onTap: {
                isPresented = true
            })
        .foregroundStyle(.white)
        .popover(isPresented: $isPresented, content: {
            List(items, id: \.self, selection: $selection) { file in
                Text(file.title)
                    .tag(file as DiskFile?)
            }
            .onAppear {
                if let asset = asset {
                    selection = DiskFile(url: asset.url)
                }
            }
            .onChange(of: selection, {
                if let s = selection {
                    playMan.play(s.toPlayAsset(), reason: "点击")
                }
            })
        })
    }
}

#Preview("APP") {
    AppPreview()
        .frame(height: 800)
}
