import SwiftUI

/// 更复杂的使用示例
struct AdvancedTooltipPreview: View {
    @State private var isToggled = false

    var body: some View {
        VStack(spacing: 30) {
            Text("高级Tooltip示例")
                .font(.largeTitle)
                .fontWeight(.bold)

            // 动态内容的tooltip
            Toggle("开关", isOn: $isToggled)
                .withTooltip(isToggled ? "当前已开启" : "当前已关闭")
                .padding()

            // 表单示例
            VStack(alignment: .leading, spacing: 15) {
                Text("表单示例")
                    .font(.headline)

                HStack {
                    Text("用户名:")
                        .withTooltip("请输入您的用户名")

                    TextField("请输入用户名", text: .constant(""))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .withTooltip("用户名长度应为3-20个字符", position: .bottom)
                }

                HStack {
                    Text("密码:")
                        .withTooltip("请输入您的密码")

                    SecureField("请输入密码", text: .constant(""))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .withTooltip(
                            "密码应包含大小写字母、数字和特殊字符",
                            position: .bottom,
                            backgroundColor: Color.yellow.opacity(0.9),
                            textColor: .black
                        )
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 5)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LinearGradient(
            gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ))
    }
}

#if DEBUG
#Preview("Advanced") {
    AdvancedTooltipPreview()
}
#endif
