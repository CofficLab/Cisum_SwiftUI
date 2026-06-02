import SwiftUI

extension MagicContainer {
    var tipsBar: some View {
        VStack(alignment: .leading) {
            Label("请按原始尺寸设计你的视图，缩放是为了方便预览", systemImage: "info")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Label("截图不支持 ScrollView、TabView 等动态视图", systemImage: "info")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Label("生成 Xcode 图标要求：视图要动态适配各种尺寸，不要硬编码尺寸；背景色不透明度为1", systemImage: "info")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview("Xcode Icon Generator") {
    Image.makeCoffeeReelIcon()
        .inMagicContainer(CGSize(width: 1024, height: 1024), scale: 0.5)
}
