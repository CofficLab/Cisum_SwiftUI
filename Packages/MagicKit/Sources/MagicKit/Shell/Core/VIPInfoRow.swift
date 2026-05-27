import SwiftUI

struct VIPInfoRow: View {
    let label: String
    let ip: String
    
    init(_ label: String, _ ip: String) {
        self.label = label
        self.ip = ip
    }
    
    var body: some View {
        HStack {
            Text("\(label):")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(ip)
                .font(.caption)
                .fontDesign(.monospaced)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(6)
    }
}
