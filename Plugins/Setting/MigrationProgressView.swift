import SwiftUI

struct MigrationProgressView: View {
    let progress: Double
    let currentFile: String
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView(value: progress) {
                Text("正在迁移数据...")
            }
            Text(currentFile)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 300)
    }
} 