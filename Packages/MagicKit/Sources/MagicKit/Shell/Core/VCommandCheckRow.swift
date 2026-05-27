import SwiftUI

#if os(macOS)
struct VCommandCheckRow: View {
    let command: String
    @State private var exists: Bool?
    
    init(_ command: String) {
        self.command = command
    }
    
    var body: some View {
        HStack {
            Text(command)
                .font(.caption)
                .fontDesign(.monospaced)
            
            Spacer()
            
            if let exists = exists {
                Image(systemName: exists ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(exists ? .green : .red)
            } else {
                ProgressView()
                    .scaleEffect(0.5)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(6)
        .onAppear {
            DispatchQueue.global(qos: .background).async {
                let commandExists = ShellSystem.commandExists(command)
                DispatchQueue.main.async {
                    exists = commandExists
                }
            }
        }
    }
}
#endif
