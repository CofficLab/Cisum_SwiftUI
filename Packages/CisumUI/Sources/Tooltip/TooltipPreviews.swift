import SwiftUI

/// Tooltip组件的预览和示例
struct TooltipPreviews: View {
    var body: some View {
        VStack(spacing: 40) {
            // 基本用法示例
            VStack(spacing: 20) {
                Text("基本Tooltip示例")
                    .font(.headline)
                
                HStack(spacing: 30) {
                    Button("悬停看提示") {
                        print("按钮被点击")
                    }
                    .withTooltip("这是一个简单的tooltip提示")
                    
                    Text("文本提示")
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                        .withTooltip("这是文本的tooltip提示")
                }
            }
            
            // 不同位置示例
            VStack(spacing: 20) {
                Text("不同位置示例")
                    .font(.headline)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                    tooltipButton("上方", position: .top)
                    tooltipButton("左上", position: .topLeading)
                    tooltipButton("右上", position: .topTrailing)
                    
                    tooltipButton("左侧", position: .leading)
                    tooltipButton("中心", position: .top) // 占位符
                    tooltipButton("右侧", position: .trailing)
                    
                    tooltipButton("左下", position: .bottomLeading)
                    tooltipButton("下方", position: .bottom)
                    tooltipButton("右下", position: .bottomTrailing)
                }
            }
            
            // 自定义样式示例
            VStack(spacing: 20) {
                Text("自定义样式示例")
                    .font(.headline)
                
                HStack(spacing: 30) {
                    Button("红色提示") {
                        print("红色按钮")
                    }
                    .withTooltip(
                        "这是红色样式的提示",
                        backgroundColor: Color.red,
                        textColor: .white,
                        cornerRadius: 12
                    )
                    
                    Button("绿色提示") {
                        print("绿色按钮")
                    }
                    .withTooltip(
                        "这是绿色样式的提示",
                        backgroundColor: Color.green,
                        textColor: .black,
                        font: .body,
                        horizontalPadding: 12,
                        verticalPadding: 8
                    )
                    
                    Button("蓝色提示") {
                        print("蓝色按钮")
                    }
                    .withTooltip(
                        "这是蓝色样式的提示",
                        backgroundColor: Color.blue.opacity(0.9),
                        textColor: .white,
                        offset: 30,
                        animationDuration: 0.5
                    )
                }
            }
            
            // 与其他组件结合使用
            VStack(spacing: 20) {
                Text("与其他组件结合")
                    .font(.headline)
                
                HStack(spacing: 20) {
                    Image(systemName: "star.fill")
                        .font(.title)
                        .foregroundColor(.yellow)
                        .withTooltip("这是一个星星图标")
                    
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 40, height: 40)
                        .withTooltip("这是一个紫色圆圈", position: .bottom)
                    
                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: 40, height: 40)
                        .cornerRadius(8)
                        .withTooltip("这是一个橙色矩形", position: .trailing)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
    }
    
    private func tooltipButton(_ title: String, position: TooltipPosition) -> some View {
        Button(title) {
            print("\(title) 被点击")
        }
        .padding()
        .background(Color.blue.opacity(0.2))
        .cornerRadius(8)
        .withTooltip("这是\(title)的tooltip", position: position)
    }
}

#if DEBUG
#Preview {
    TooltipPreviews()
        
}
#endif
