import SwiftUI
import MagicPlayMan

/**
 展示图书的章节
 */
struct ChapterTile: View {
    @EnvironmentObject var playMan: MagicPlayMan
    
    var file: URL
    
    var chapters: [URL] { file.getChildren() }
    
    var body: some View {
        Text(file.title)
    }
}

#Preview {
    AppPreview()
        .frame(height: 800)
}
