import SwiftUI

/**
 展示图书的章节
 */
struct ChapterTile: View {
    @EnvironmentObject var playMan: PlayMan
    
    var file: DiskFile
    
    var chapters: [DiskFile] { file.children ?? []}
    
    var body: some View {
        Text(file.title)
    }
}

#Preview {
    AppPreview()
        .frame(height: 800)
}
