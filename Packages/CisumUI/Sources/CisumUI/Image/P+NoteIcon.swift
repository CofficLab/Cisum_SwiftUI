import SwiftUI

#if DEBUG
/// 笔记图标预览
struct NoteIconPreviews: View {
    var body: some View {
        IconPreviewHelper(title: "Note Icon") {
            Image.makeNoteIcon()
        }
    }
}

#Preview {
    NoteIconPreviews()
}
#endif
