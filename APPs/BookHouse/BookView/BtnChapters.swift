import OSLog
import SwiftData
import SwiftUI

struct BtnChapters: View {
    @EnvironmentObject var app: AppProvider
    @EnvironmentObject var data: DataProvider
    @EnvironmentObject var playMan: PlayMan
    @EnvironmentObject var db: DBSynced
    
    @State var isPresented = false
    @State var selection: DiskFile?
    
    var asset: PlayAsset? { playMan.asset }
    var bookURL: URL? { asset?.url.deletingLastPathComponent() ?? nil }
    var items: [DiskFile] {
        guard let bookURL = bookURL else {
            return []
        }
        
        return DiskFile(url: bookURL).children ?? []
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
                ChapterTile(file: file)
                    .tag(file as DiskFile?)
            }
            .onAppear {
                if let asset = asset {
                    selection = DiskFile(url: asset.url)
                }
            }
//            .onChange(of: selection, {
//                if let s = selection, let bookURL = bookURL, s.url != asset?.url {
//                    playMan.play(s.toPlayAsset(), reason: "BtnChapters的Selection变了")
//                    data.updateBookState(bookURL, s.url)
//                }
//            })
        })
    }
}

#Preview("APP") {
    AppPreview()
        .frame(height: 800)
}
