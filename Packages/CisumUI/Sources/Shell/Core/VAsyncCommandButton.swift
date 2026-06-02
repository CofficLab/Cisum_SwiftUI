import SwiftUI
#if os(macOS)
struct VAsyncCommandButton: View {
    @State private var isLoading = false
    @State private var result = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                executeAsyncCommand()
            }) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("执行中...")
                    } else {
                        Text("异步执行长时间命令")
                        Spacer()
                        Image(systemName: "play.circle")
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isLoading)
            
            if !result.isEmpty {
                Text("结果: \(result)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func executeAsyncCommand() {
        isLoading = true
        result = ""
        
        Task {
            do {
                let output = try await Shell.runSync("sleep 2 && echo 'Async command completed!'")
                await MainActor.run {
                    result = output
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    result = "错误: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}

#endif
