import SwiftUI

/// 条件显示预览视图
struct ConditionalSimplePreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("条件显示示例")
                .font(.title)
                .padding()

            // 显示的视图
            GroupBox("条件为 true") {
                Text("这段文字会显示")
                    .if(true)
            }

            // 隐藏的视图
            GroupBox("条件为 false") {
                Text("这段文字不会显示")
                    .if(false)
            }

            // 使用变量
            let isLoggedIn = true
            GroupBox("使用变量条件") {
                VStack {
                    Text("欢迎回来！")
                        .if(isLoggedIn)
                    Text("请先登录")
                        .if(!isLoggedIn)
                }
            }
        }
        .padding()
    }
}

#if DEBUG
    #Preview("Conditional View - Simple") {
        ConditionalSimplePreview()
            .frame(height: 600)
            .frame(width: 500)
    }
#endif
