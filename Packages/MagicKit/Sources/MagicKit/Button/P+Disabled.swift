import SwiftUI

#if DEBUG
    /// Button Disabled with Reason Previews
    struct DisabledWithReasonPreviews: View {
        @State private var isFormValid = false
        @State private var hasPermission = false
        @State private var isConnected = true

        var body: some View {
            VStack(spacing: 30) {
                Text("按钮禁用原因示例")
                    .font(.title)
                    .fontWeight(.semibold)

                // 基本用法
                VStack(alignment: .leading, spacing: 15) {
                    Text("基本用法")
                        .font(.headline)

                    VStack(spacing: 12) {
//                        Button("正常按钮") {
//                            print("正常点击")
//                        }
//                        .buttonStyle(.borderedProminent)

                        Button("禁用的按钮（固定禁用）") {
                            print("这个不会执行")
                        }
                        .buttonStyle(.borderedProminent)
                        .disabledWithReason("请先完成上一步操作")

//                        Button("另一个禁用的按钮") {
//                            print("这个也不会执行")
//                        }
//                        .buttonStyle(.bordered)
//                        .disabledWithReason("您没有权限执行此操作，请联系管理员")
                    }
                }
                .withDivider(spacing: 10)

                // 动态禁用
//                VStack(alignment: .leading, spacing: 15) {
//                    Text("动态禁用")
//                        .font(.headline)
//
//                    VStack(spacing: 12) {
//                        Toggle("表单是否有效", isOn: $isFormValid)
//
//                        Button("提交表单") {
//                            print("提交表单")
//                        }
//                        .buttonStyle(.borderedProminent)
//                        .disabledWithReason(!isFormValid, reason: "请先填写所有必填项并同意条款")
//
//                        Toggle("是否有权限", isOn: $hasPermission)
//
//                        Button("执行管理操作") {
//                            print("执行管理操作")
//                        }
//                        .buttonStyle(.bordered)
//                        .disabledWithReason(!hasPermission, reason: "您需要管理员权限才能执行此操作")
//
//                        Toggle("网络连接", isOn: $isConnected)
//
//                        Button("同步数据") {
//                            print("同步数据")
//                        }
//                        .buttonStyle(.bordered)
//                        .disabledWithReason(!isConnected, reason: "网络连接断开，请检查网络设置后重试")
//                    }
//                }

                // 不同场景
//                VStack(alignment: .leading, spacing: 15) {
//                    Text("实际应用场景")
//                        .font(.headline)
//
//                    VStack(spacing: 12) {
//                        Button("保存草稿") {
//                            print("保存草稿")
//                        }
//                        .buttonStyle(.bordered)
//                        .disabledWithReason("草稿内容为空，无法保存")
//
//                        Button("发布文章") {
//                            print("发布文章")
//                        }
//                        .buttonStyle(.borderedProminent)
//                        .disabledWithReason("文章标题不能为空，请先填写标题")
//
//                        Button("导出数据") {
//                            print("导出数据")
//                        }
//                        .buttonStyle(.bordered)
//                        .disabledWithReason("当前没有可导出的数据，请先添加数据")
//                    }
//                }
            }
            .padding()
            .infinite()
            .inScrollView()
        }
    }

    #if DEBUG
    #Preview("Button Disabled with Reason") {
        DisabledWithReasonPreviews()
            .frame(width: 500, height: 700)
    }
    #endif
#endif
