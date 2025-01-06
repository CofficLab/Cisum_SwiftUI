import SwiftUI
import MagicPlayMan

/**
 展示图书的章节
 */
struct ChapterTile: View {
    @EnvironmentObject var playMan: MagicPlayMan
    
    var file: DiskFile
    
    var chapters: [DiskFile] { file.children ?? []}
    
    var body: some View {
        Text(file.url.title)
    }
}

#Preview {
    AppPreview()
        .frame(height: 800)
}
