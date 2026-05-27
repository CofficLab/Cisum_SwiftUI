import SwiftUI
#if os(macOS)
struct VHTTPStatusRow: View {
    let url: String
    @State private var statusCode: Int?
    @State private var isLoading = false
    
    init(_ url: String) {
        self.url = url
    }
    
    var body: some View {
        HStack {
            Text(url)
                .font(.caption)
                .fontDesign(.monospaced)
                .lineLimit(1)
            
            Spacer()
            
            if isLoading {
                ProgressView()
                    .scaleEffect(0.5)
            } else if let statusCode = statusCode {
                Text("\(statusCode)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(statusColor(statusCode))
            } else {
                Button("测试") {
                    testHTTP()
                }
                .font(.caption)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(6)
        .onAppear {
            testHTTP()
        }
    }
    
    private func testHTTP() {
        isLoading = true
        DispatchQueue.global(qos: .background).async {
            let status = ShellNetwork.getHTTPStatus(url)
            DispatchQueue.main.async {
                statusCode = status
                isLoading = false
            }
        }
    }
    
    private func statusColor(_ code: Int) -> Color {
        switch code {
        case 200..<300: return .green
        case 300..<400: return .orange
        case 400..<500: return .red
        case 500..<600: return .purple
        default: return .gray
        }
    }
}
#endif
