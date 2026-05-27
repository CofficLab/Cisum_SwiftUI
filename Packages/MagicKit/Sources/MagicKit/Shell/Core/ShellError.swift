import SwiftUI

enum ShellError: Error, LocalizedError {
    case commandFailed(String, String)
    case stringConversionFailed(Data)
    case processStartFailed(String)

    var errorDescription: String? {
        switch self {
        case let .commandFailed(output, command):
            return "Command failed with output: \n\(output)\nCommand: \n\(command)"
        case let .stringConversionFailed(data):
            return "Failed to convert command output data to UTF-8 string. Data size: \(data.count) bytes"
        case let .processStartFailed(message):
            return "Failed to start process: \(message)"
        }
    }
}

// MARK: - Preview

#if DEBUG && os(macOS)
#Preview("Shell Demo") {
    ShellDemoView()
        .padding()
        
}
#endif
