import SwiftUI

/// 带 else 分支的条件显示预览视图
struct ConditionalWithElsePreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("带 else 分支的条件显示")
                .font(.title)
                .padding()

            VStack(spacing: 16) {
                // 有权限时显示按钮，否则显示提示
                GroupBox("有权限") {
                    Button("删除") { }
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .if(true, otherwise: {
                            Text("没有删除权限")
                                .foregroundColor(.red)
                        })
                }

                GroupBox("无权限") {
                    Button("删除") { }
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .if(false, otherwise: {
                            Text("没有删除权限")
                                .foregroundColor(.red)
                                .font(.body)
                        })
                }
            }
        }
        .padding()
    }
}

#if DEBUG
#Preview("Conditional View - With Else") {
    ConditionalWithElsePreview()
}
#endif
