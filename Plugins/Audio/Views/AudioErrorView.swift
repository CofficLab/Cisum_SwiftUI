import SwiftUI
import Foundation

/// 音频错误视图
/// 用于展示音频插件中的各种错误，提供用户友好的错误信息和恢复建议
struct AudioErrorView: View {
    let error: Error
    let title: String
    let onRetry: (() -> Void)?
    let onDismiss: (() -> Void)?
    
    init(
        error: Error,
        title: String = "音频错误",
        onRetry: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.error = error
        self.title = title
        self.onRetry = onRetry
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // 错误图标
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            // 错误标题
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            // 错误描述
            VStack(spacing: 12) {
                if let localizedError = error as? LocalizedError {
                    if let errorDescription = localizedError.errorDescription {
                        Text(errorDescription)
                            .font(.body)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                    }
                    
                    if let failureReason = localizedError.failureReason {
                        Text(failureReason)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    if let recoverySuggestion = localizedError.recoverySuggestion {
                        Text(recoverySuggestion)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    Text(error.localizedDescription)
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal)
            
            // 错误代码（用于调试）
            if let nsError = error as NSError? {
                VStack(spacing: 8) {
                    Text("错误代码: \(nsError.code)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if !nsError.domain.isEmpty {
                        Text("错误域: \(nsError.domain)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 8)
            }
            
            // 操作按钮
            HStack(spacing: 16) {
                if let onRetry = onRetry {
                    Button("重试") {
                        onRetry()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                if let onDismiss = onDismiss {
                    Button("关闭") {
                        onDismiss()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.top, 8)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 20)
    }
}

/// 音频错误弹窗视图
struct AudioErrorAlert: ViewModifier {
    let error: Error?
    let title: String
    let onRetry: (() -> Void)?
    let onDismiss: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: .constant(error != nil)) {
                if let onRetry = onRetry {
                    Button("重试", action: onRetry)
                }
                
                if let onDismiss = onDismiss {
                    Button("关闭", action: onDismiss)
                } else {
                    Button("确定") { }
                }
            } message: {
                if let error = error {
                    if let localizedError = error as? LocalizedError {
                        Text(localizedError.errorDescription ?? error.localizedDescription)
                    } else {
                        Text(error.localizedDescription)
                    }
                }
            }
    }
}

/// 音频错误横幅视图
struct AudioErrorBanner: View {
    let error: Error
    let onRetry: (() -> Void)?
    let onDismiss: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 12) {
            // 错误图标
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            
            // 错误信息
            VStack(alignment: .leading, spacing: 4) {
                if let localizedError = error as? LocalizedError {
                    if let errorDescription = localizedError.errorDescription {
                        Text(errorDescription)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    if let recoverySuggestion = localizedError.recoverySuggestion {
                        Text(recoverySuggestion)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text(error.localizedDescription)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
            }
            
            Spacer()
            
            // 操作按钮
            HStack(spacing: 8) {
                if let onRetry = onRetry {
                    Button("重试") {
                        onRetry()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                
                if let onDismiss = onDismiss {
                    Button("×") {
                        onDismiss()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - 预览

#Preview("错误视图") {
    ScrollView {
        VStack(spacing: 20) {
            AudioErrorView(
                error: AudioPluginError.NoDisk,
                title: "磁盘访问错误"
            ) {
                print("重试操作")
            } onDismiss: {
                print("关闭错误")
            }
            
            AudioErrorView(
                error: AudioRecordDBError.AudioNotFound(URL(fileURLWithPath: "/test/audio.mp3")),
                title: "音频文件未找到"
            ) {
                print("重试操作")
            } onDismiss: {
                print("关闭错误")
            }
            
            AudioErrorView(
                error: AudioModelError.fileCorrupted(URL(fileURLWithPath: "/test/corrupted.mp3")),
                title: "文件损坏"
            ) {
                print("重试操作")
            } onDismiss: {
                print("关闭错误")
            }
        }
        .padding()
    }
    .background(Color.gray.opacity(0.1))
}

#Preview("错误横幅") {
    VStack(spacing: 16) {
        AudioErrorBanner(
            error: AudioPluginError.initialization(reason: "配置加载失败")
        ) {
            print("重试操作")
        } onDismiss: {
            print("关闭错误")
        }
        
        AudioErrorBanner(
            error: AudioRepoError.fileSystemError(operation: "读取文件", path: "/test/path")
        ) {
            print("重试操作")
        } onDismiss: {
            print("关闭错误")
        }
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
