import SwiftUI
import OSLog

struct VDemoButtonWithLog: View {
    let title: String
    let action: (() -> String?)
    
    @State private var logs: [String] = []
    @State private var isLogExpanded: Bool = false
    
    init(_ title: String, action: @escaping () -> String?) {
        self.title = title
        self.action = action
    }
    
    private func appendLog(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        logs.insert("\(timestamp): \(message)", at: 0)
        if logs.count > 20 { // Keep only the latest 20 logs
            logs = Array(logs.prefix(20))
        }
        os_log("%@: %@", type: .info, title, message)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Button(action: {
                logs.removeAll() // Clear logs on each action
                isLogExpanded = true // Expand log on action
                appendLog("执行: \(title)")
                if let result = action() { // Perform the actual action and capture result
                    appendLog("结果: \(result)")
                }
            }) {
                HStack {
                    Text(title)
                    Spacer()
                    Image(systemName: "play.circle")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            
            if !logs.isEmpty {
                DisclosureGroup(isExpanded: $isLogExpanded) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(logs, id: \.self) { log in
                                Text(log)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(5)
                    }
                    .frame(maxHeight: 150) // Limit scroll view height
                } label: {
                    Text("日志 (\(logs.count))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 5)
            }
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 5)
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }
} 