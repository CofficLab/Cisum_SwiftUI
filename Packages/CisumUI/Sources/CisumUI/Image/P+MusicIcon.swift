import SwiftUI

#if DEBUG
/// 音乐图标预览
struct MusicIconPreviews: View {
    var body: some View {
        IconPreviewHelper(title: "Music Icon") {
            Image.makeMusicIcon()
        }
    }
}

#Preview {
    MusicIconPreviews()
}
#endif
