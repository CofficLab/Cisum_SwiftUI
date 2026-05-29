import SwiftUI
#if os(macOS)
struct VCommandAvailabilityRow: View {
    let command: String
    @State private var isAvailable: Bool?
    @State private var commandPath: String?
    
    init(_ command: String) {
        self.command = command
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(command)
                    .font(.caption)
                    .fontDesign(.monospaced)
                
                Spacer()
                
                if let isAvailable = isAvailable {
                    Image(systemName: isAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(isAvailable ? .green : .red)
                } else {
                    ProgressView()
                        .scaleEffect(0.5)
                }
            }
            
            if let path = commandPath {
                Text(path)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .fontDesign(.monospaced)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(6)
        .onAppear {
            checkCommand()
        }
    }
    
    private func checkCommand() {
        DispatchQueue.global(qos: .background).async {
            let available = Shell.isCommandAvailable(command)
            let path = Shell.getCommandPath(command)
            
            DispatchQueue.main.async {
                isAvailable = available
                commandPath = path
            }
        }
    }
}
#endif
