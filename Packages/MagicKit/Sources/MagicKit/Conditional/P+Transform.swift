import SwiftUI

/// 条件修饰符预览视图
struct ConditionalTransformPreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("条件修饰符")
                .font(.title)
                .padding()

            VStack(spacing: 16) {
                // 高亮状态
                GroupBox("高亮") {
                    Text("重要消息")
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .if(true) { view in
                            view.background(Color.yellow.opacity(0.3))
                        }
                }

                // 普通状态
                GroupBox("普通") {
                    Text("普通消息")
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .if(false) { view in
                            view.background(Color.yellow.opacity(0.3))
                        }
                }

                // 禁用状态
                GroupBox("禁用按钮") {
                    Button("点击我") { }
                        .if(true) { view in
                            view.disabled(true)
                                .opacity(0.5)
                        }
                }
            }
        }
        .padding()
    }
}

#if DEBUG
#Preview("Conditional View - Transform") {
    ConditionalTransformPreview()
}
#endif
