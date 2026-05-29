import SwiftUI

public extension Image {
    /**
        创建咖啡卷图标

        ## 参数
        - `useDefaultBackground`: 是否使用默认的绿色渐变背景，默认为 true
        - `plateColor`: 盘子边框的颜色，默认为白色
        - `size`: 图标的大小，如果为 nil 则使用容器默认大小

        ## 返回值
        一个包含咖啡卷图标的视图

        ## 示例
        ```swift
        // 创建默认咖啡卷图标
        Image.makeCoffeeReelIcon()

        // 创建自定义咖啡卷图标
        Image.makeCoffeeReelIcon(
            useDefaultBackground: false,
            plateColor: .brown,
            size: 100
        )
        ```
     */
    static func makeCoffeeReelIcon(
        useDefaultBackground: Bool = true,
        plateColor: Color = .white,
        handleRotation: Double = 30,
        size: CGFloat? = nil
    ) -> some View {
        IconContainer(size: size) {
            CoffeeReelIcon(
                useDefaultBackground: useDefaultBackground,
                plateColor: plateColor,
                handleRotation: handleRotation
            )
        }
    }
}
