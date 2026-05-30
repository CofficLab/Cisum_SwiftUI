import SwiftUI

/// 实际应用示例预览视图
struct ConditionalRealWorldPreview: View {
    struct User {
        let isLoggedIn: Bool
        let isAdmin: Bool
        let hasPermission: Bool
    }

    let user = User(isLoggedIn: true, isAdmin: false, hasPermission: false)

    var body: some View {
        VStack(spacing: 20) {
            Text("实际应用示例")
                .font(.title)
                .padding()

            VStack(alignment: .leading, spacing: 16) {
                // 用户信息卡片
                GroupBox("用户信息") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("欢迎！")
                            .font(.headline)

                        // 根据登录状态显示不同内容
                        if user.isLoggedIn {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("用户名：John Doe")
                                Text("角色：\(user.isAdmin ? "管理员" : "普通用户")")
                            }
                        } else {
                            Text("请先登录")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // 操作按钮
                GroupBox("操作") {
                    VStack(spacing: 12) {
                        Button("编辑") { }
                            .if(user.hasPermission, otherwise: {
                                Text("没有编辑权限")
                                    .foregroundColor(.red)
                            })

                        Button("删除") { }
                            .if(user.isAdmin, otherwise: {
                                Text("仅管理员可删除")
                                    .foregroundColor(.secondary)
                            })
                    }
                }
            }
        }
        .padding()
    }
}

#if DEBUG
    #Preview("Conditional View - Real World") {
        ConditionalRealWorldPreview()
    }
#endif
