import SwiftUI

struct TableHeaderView: View {
    var body: some View {
        HStack(spacing: 4) {
            // 名称列
            HStack {
                Text("名称")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 40)  // 为图标和缩进留出空间
            
            // 大小和状态列
            HStack(spacing: 8) {
                Text("状态")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .frame(minWidth: 60, alignment: .trailing)
                
                Text("大小")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .frame(minWidth: 80, alignment: .trailing)
            }
            .padding(.trailing, 4)
        }
        .padding(.vertical, 4)
        .background(Color.secondary.opacity(0.05))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.secondary.opacity(0.2)),
            alignment: .bottom
        )
    }
} 
