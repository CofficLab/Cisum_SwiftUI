import SwiftUI
import MagicKit

/**
 展示从磁盘读取的图书数据
 */
struct BookTileBackup: View {
    @EnvironmentObject var playMan: PlayMan
    
    var file: DiskFile
    
    var chapters: [DiskFile] { file.children ?? []}
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Text(file.title).font(.title)
                Spacer()
                Text("共 \(chapters.count)")
                Spacer()
            }
            Spacer()
        }
        .background(BackgroundView.type2A)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
        .onTapGesture {
            playMan.play(file.toPlayAsset(), reason: "点击了书本")
        }
        .contextMenu(menuItems: {
            BtnShowInFinder(url: file.url, autoResize: false)
        })
    }
}

#Preview {
    AppPreview()
        .frame(height: 800)
}
