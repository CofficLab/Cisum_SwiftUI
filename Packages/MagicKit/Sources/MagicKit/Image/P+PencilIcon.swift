import SwiftUI

#if DEBUG
/// 铅笔图标预览
struct PencilIconPreviews: View {
    var body: some View {
        IconPreviewHelper(title: "Pencil Icon") {
            Image.makePencilIcon()
        }
    }
}

#Preview {
    PencilIconPreviews()
}
#endif
