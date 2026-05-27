import SwiftUI

/// 条件修饰符（带 else）预览视图
struct ConditionalTransformWithElsePreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("条件修饰符（带 else）")
                .font(.title)
                .padding()

            VStack(spacing: 16) {
                // 成功状态
                GroupBox("成功") {
                    Text("操作成功")
                        .padding()
                        .if(true, if: { view in
                            view
                                .foregroundColor(.green)
                                .background(Color.green.opacity(0.1))
                        }, otherwise: { view in
                            view
                                .foregroundColor(.red)
                                .background(Color.red.opacity(0.1))
                        })
                }

                // 失败状态
                GroupBox("失败") {
                    Text("操作失败")
                        .padding()
                        .if(false, if: { view in
                            view
                                .foregroundColor(.green)
                                .background(Color.green.opacity(0.1))
                        }, otherwise: { view in
                            view
                                .foregroundColor(.red)
                                .background(Color.red.opacity(0.1))
                        })
                }
            }
        }
        .padding()
    }
}

#if DEBUG
#Preview("Conditional View - Transform With Else") {
    ConditionalTransformWithElsePreview()
}
#endif
