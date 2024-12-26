import SwiftUI

struct MigrationConfirmationView: View {
    let onConfirm: () -> Void
    let onSkipMigration: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            // 标题和说明部分
            VStack(alignment: .leading, spacing: 12) {
                Text("是否需要迁移现有数据到新位置？")
                    .font(.headline)
                    .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 8) {
                    BulletPoint("迁移数据：将现有数据迁移到新位置")
                    BulletPoint("直接使用：直接使用新位置，原有数据保持不变")
                    BulletPoint("取消操作：保持原位置不变")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            
            // 按钮部分
            HStack(spacing: 12) {
                Button("取消操作") {
                    onCancel()
                }
                .buttonStyle(.bordered)
                
                Button("直接使用") {
                    onSkipMigration()
                }
                .buttonStyle(.borderedProminent)
                
                Button("迁移数据") {
                    onConfirm()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .frame(maxWidth: 500)
    }
}

// 辅助视图：带圆点的文本行
private struct BulletPoint: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    MigrationConfirmationView(
        onConfirm: {},
        onSkipMigration: {},
        onCancel: {}
    )
    .frame(width: 500)
} 
