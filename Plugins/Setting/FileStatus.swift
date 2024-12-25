import Foundation
import SwiftUICore

struct FileStatus: Identifiable {
    let id = UUID()
    let name: String
    let status: Status

    enum Status {
        case pending
        case processing
        case completed
        case failed(String)

        var icon: String {
            switch self {
            case .pending: return "circle"
            case .processing: return "arrow.clockwise"
            case .completed: return "checkmark.circle.fill"
            case .failed: return "exclamationmark.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .pending: return .secondary
            case .processing: return .blue
            case .completed: return .green
            case .failed: return .red
            }
        }
    }
}
