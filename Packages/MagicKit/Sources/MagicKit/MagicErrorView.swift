import SwiftUI

/// 用于展示详细错误信息的视图组件
public struct MagicErrorView: View {
    let error: Error
    let title: String?
    let onDismiss: (() -> Void)?
    @State private var showCopied = false
    @State private var isExpanded = false
    
    public init(error: Error, title: String? = nil, onDismiss: (() -> Void)? = nil) {
        self.error = error
        self.title = title
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 错误图标和标题
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .font(.title2)
                
                Text(title ?? "错误详情")
                    .font(.headline)
                
                Spacer()
                
                // 复制按钮
                Button {
                    copyErrorInfo()
                } label: {
                    Label(showCopied ? "已复制" : "复制", systemImage: showCopied ? "checkmark.circle.fill" : "doc.on.doc")
                        .foregroundStyle(showCopied ? .green : .blue)
                        .animation(.default, value: showCopied)
                }
                .buttonStyle(.borderless)
                
                // 关闭按钮（如果提供了 onDismiss）
                if let onDismiss = onDismiss {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.title2)
                    }
                    .buttonStyle(.borderless)
                }
            }
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // 错误描述
                    ErrorSection(title: "错误描述", content: error.localizedDescription)
                    
                    // 失败原因
                    if let failureReason = (error as? LocalizedError)?.failureReason {
                        ErrorSection(title: "失败原因", content: failureReason)
                    }
                    
                    // 恢复建议
                    if let recoverySuggestion = (error as? LocalizedError)?.recoverySuggestion {
                        ErrorSection(title: "恢复建议", content: recoverySuggestion)
                    }
                    
                    // NSError 详细信息
                    if let nsError = error as? NSError {
                        // 错误域和代码
                        if nsError.domain != "NSCocoaErrorDomain" || nsError.code != 0 {
                            ErrorSection(title: "错误信息", content: "域: \(nsError.domain)\n代码: \(nsError.code)")
                        }
                        
                        // 帮助信息
                        if let helpAnchor = nsError.helpAnchor, !helpAnchor.isEmpty {
                            ErrorSection(title: "帮助信息", content: helpAnchor)
                        }
                        
                        // 底层错误
                        if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? NSError {
                            ErrorSection(title: "底层错误", content: underlyingError.localizedDescription)
                        }
                    }
                    
                    // 调试信息（仅在DEBUG模式下显示）
                    #if DEBUG
                    if let debugInfo = getDebugInfo() {
                        DisclosureGroup(
                            isExpanded: $isExpanded,
                            content: {
                                Text(debugInfo)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                    .textSelection(.enabled)
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                            },
                            label: {
                                Label("调试信息", systemImage: "ladybug")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        )
                        .padding(.top, 8)
                    }
                    #endif
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .frame(idealWidth: 600)
        .padding(.horizontal, 20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 8)
    }
    
    private func copyErrorInfo() {
        var errorInfo = [String]()
        
        errorInfo.append("错误描述：\n\(error.localizedDescription)")
        
        if let failureReason = (error as? LocalizedError)?.failureReason {
            errorInfo.append("\n失败原因：\n\(failureReason)")
        }
        
        if let recoverySuggestion = (error as? LocalizedError)?.recoverySuggestion {
            errorInfo.append("\n恢复建议：\n\(recoverySuggestion)")
        }
        
        // 添加 NSError 信息
        if let nsError = error as? NSError {
            if nsError.domain != "NSCocoaErrorDomain" || nsError.code != 0 {
                errorInfo.append("\n错误信息：\n域: \(nsError.domain)\n代码: \(nsError.code)")
            }
            
            if let helpAnchor = nsError.helpAnchor, !helpAnchor.isEmpty {
                errorInfo.append("\n帮助信息：\n\(helpAnchor)")
            }
            
            if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? NSError {
                errorInfo.append("\n底层错误：\n\(underlyingError.localizedDescription)")
            }
        }
        
        let fullErrorInfo = errorInfo.joined(separator: "\n")
        fullErrorInfo.copy()
        
        showCopied = true
        
        // 2秒后重置复制状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showCopied = false
        }
    }
    
    private func getDebugInfo() -> String? {
        #if DEBUG
        var debugInfo: [String] = []
        
        // 完整的错误描述
        debugInfo.append("完整错误: \(error)")
        
        // 调试描述（如果可用）
        let debugDescription = String(reflecting: error)
        let errorDescription = "\(error)"
        if debugDescription != errorDescription && !debugDescription.isEmpty {
            debugInfo.append("调试描述: \(debugDescription)")
        }
        
        // NSError 的用户信息
        if let nsError = error as? NSError, !nsError.userInfo.isEmpty {
            debugInfo.append("用户信息: \(nsError.userInfo)")
        }
        
        return debugInfo.isEmpty ? nil : debugInfo.joined(separator: "\n\n")
        #else
        return nil
        #endif
    }
}

/// 错误信息区域组件
private struct ErrorSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(content)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
