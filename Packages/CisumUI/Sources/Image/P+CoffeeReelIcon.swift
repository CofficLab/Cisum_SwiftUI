import SwiftUI

#if DEBUG
/// 咖啡卷图标预览
/// 展示不同配置下的咖啡卷图标效果
struct CoffeeReelIconPreviews: View {
    var body: some View {
        TabView {
            // 默认配置：绿色背景，白色盘子
            VStack {
                IconPreviewHelper(title: "Coffee Reel Icon (Default)") {
                    Image.makeCoffeeReelIcon()
                }
            }
            .tabItem {
                Label("默认", systemImage: "leaf.fill")
            }

            // 自定义配置：无背景，棕色盘子
            VStack {
                Image.makeCoffeeReelIcon(
                    useDefaultBackground: false,
                    plateColor: .brown
                )
                .frame(height: 200)
                .frame(width: 200)
            }
            .tabItem {
                Label("棕色盘子", systemImage: "circle.fill")
            }

            // 自定义配置：无背景，蓝色盘子
            VStack {
                Image.makeCoffeeReelIcon(
                    useDefaultBackground: false,
                    plateColor: .blue
                )
                .frame(height: 200)
                .frame(width: 200)
            }
            .tabItem {
                Label("蓝色盘子", systemImage: "circle.fill")
            }

            // 自定义配置：无背景，红色盘子
            VStack {
                Image.makeCoffeeReelIcon(
                    useDefaultBackground: false,
                    plateColor: .red
                )
                .frame(width: 200)
                .frame(height: 200)
            }
            .tabItem {
                Label("红色盘子", systemImage: "circle.fill")
            }

            // 自定义配置：不同手柄角度
            VStack(spacing: 20) {
                Image.makeCoffeeReelIcon(
                    useDefaultBackground: true,
                    handleRotation: -90
                )
                .frame(height: 200)
                .frame(width: 200)

                // 0度手柄
                Image.makeCoffeeReelIcon(
                    useDefaultBackground: true,
                    handleRotation: 0
                )
                .frame(height: 200)
                .frame(width: 200)

                // 30度手柄
                Image.makeCoffeeReelIcon(
                    useDefaultBackground: true,
                    handleRotation: 30
                )
                .frame(height: 200)
                .frame(width: 200)

                // 45度手柄
                Image.makeCoffeeReelIcon(
                    useDefaultBackground: true,
                    handleRotation: 45
                )
                .frame(height: 200)
                .frame(width: 200)

                // 90度手柄
                Image.makeCoffeeReelIcon(
                    useDefaultBackground: true,
                    handleRotation: 90
                )
                .frame(height: 200)
                .frame(width: 200)
            }
            .tabItem {
                Label("手柄角度", systemImage: "rotate.right")
            }
        }
        .inScrollView()
    }
}

#Preview("Coffee Reel Icon") {
    CoffeeReelIconPreviews()
        .frame(width: 500)
        .frame(height: 600)
}
#endif
