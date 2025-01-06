import SwiftUI
import MagicKit
import MagicUI
import MagicPlayMan

/**
 展示从磁盘读取的图书数据
 */
struct BookTileBackup: View {
    @EnvironmentObject var playMan: MagicPlayMan
    
    var file: DiskFile
    
    var chapters: [DiskFile] { file.children ?? []}
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Text(file.url.title).font(.title)
                Spacer()
                Text("共 \(chapters.count)")
                Spacer()
            }
            Spacer()
        }
        .background(MagicBackground.blueberry)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
        .onTapGesture {
//            playMan.play(file.toPlayAsset(), reason: "点击了书本", verbose: true)
        }
        .contextMenu(menuItems: {
            file.url.makeOpenButton()
        })
    }
}

#Preview {
    AppPreview()
        .frame(height: 800)
}
