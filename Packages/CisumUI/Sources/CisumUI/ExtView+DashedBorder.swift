import SwiftUI

extension View {
    /// 为视图添加虚线边框
    /// - Parameters:
    ///   - color: 虚线颜色，默认为灰色
    ///   - lineWidth: 线宽，默认为1
    ///   - dash: 虚线样式，默认为[5,5]表示线段长5点，间隔5点
    public func dashedBorder(
        color: Color = .gray,
        lineWidth: CGFloat = 1,
        dash: [CGFloat] = [5, 5]
    ) -> some View {
        self.overlay(
            Rectangle()
                .strokeBorder(style: StrokeStyle(
                    lineWidth: lineWidth,
                    dash: dash
                ))
                .foregroundColor(color)
        )
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Dashed Border") {
    VStack(spacing: 20) {
        // 默认样式
        Text("Default Style")
            .padding()
            .dashedBorder()
        
        // 自定义颜色
        Text("Custom Color")
            .padding()
            .dashedBorder(color: .blue)
        
        // 自定义线宽
        Text("Thick Border")
            .padding()
            .dashedBorder(color: .red, lineWidth: 3)
        
        // 自定义虚线样式
        Text("Custom Dash Pattern")
            .padding()
            .dashedBorder(color: .green, dash: [10, 5])
        
        // 应用于图片
        Image(systemName: "star.fill")
            .font(.largeTitle)
            .padding()
            .dashedBorder(color: .orange, lineWidth: 2, dash: [8, 4])
        
        // 添加 onlyDebug 预览示例
        Text("Debug Only View")
            .padding()
            .background(Color.yellow)
            .onlyDebug()
    }
    .padding()
    
}
#endif
