import SwiftUI
#if os(macOS)
struct VPortTestRow: View {
    let host: String
    let port: Int
    @State private var isOpen: Bool?
    @State private var isLoading = false
    
    init(_ host: String, _ port: Int) {
        self.host = host
        self.port = port
    }
    
    var body: some View {
        HStack {
            Text("\(host):\(port)")
                .font(.caption)
                .fontDesign(.monospaced)
            
            Spacer()
            
            if isLoading {
                ProgressView()
                    .scaleEffect(0.5)
            } else if let isOpen = isOpen {
                Image(systemName: isOpen ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isOpen ? .green : .red)
            } else {
                Button("测试") {
                    testPort()
                }
                .font(.caption)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(6)
        .onAppear {
            testPort()
        }
    }
    
    private func testPort() {
        isLoading = true
        DispatchQueue.global(qos: .background).async {
            let open = ShellNetwork.testPort(host, port: port)
            DispatchQueue.main.async {
                isOpen = open
                isLoading = false
            }
        }
    }
}
#endif
