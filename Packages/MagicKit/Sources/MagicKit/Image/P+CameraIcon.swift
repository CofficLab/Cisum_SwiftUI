import SwiftUI

#if DEBUG
/// 相机图标预览
struct CameraIconPreviews: View {
    var body: some View {
        IconPreviewHelper(title: "Camera Icon") {
            Image.makeCameraIcon()
        }
    }
}

#Preview {
    CameraIconPreviews()
}
#endif
