import SwiftUI
#if os(macOS)
struct VPingTestRow: View {
    let host: String
    @State private var isReachable: Bool?
    @State private var isLoading = false
    
    init(_ host: String) {
        self.host = host
    }
    
    var body: some View {
        HStack {
            Text(host)
                .font(.caption)
                .fontDesign(.monospaced)
            
            Spacer()
            
            if isLoading {
                ProgressView()
                    .scaleEffect(0.5)
            } else if let isReachable = isReachable {
                Image(systemName: isReachable ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isReachable ? .green : .red)
            } else {
                Button("测试") {
                    testConnection()
                }
                .font(.caption)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(6)
        .onAppear {
            testConnection()
        }
    }
    
    private func testConnection() {
        isLoading = true
        DispatchQueue.global(qos: .background).async {
            let reachable = ShellNetwork.ping(host)
            DispatchQueue.main.async {
                isReachable = reachable
                isLoading = false
            }
        }
    }
}
#endif
