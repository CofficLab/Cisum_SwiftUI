import Foundation
import SwiftUICore

struct FileStatus: Identifiable {
    let id = UUID()
    let name: String
    let status: Status

    enum Status: Equatable {
        case pending
        case processing
        case completed
        case failed(String)

        static func == (lhs: Status, rhs: Status) -> Bool {
            switch (lhs, rhs) {
            case (.pending, .pending):
                return true
            case (.processing, .processing):
                return true
            case (.completed, .completed):
                return true
            case (.failed(let lhsMessage), .failed(let rhsMessage)):
                return lhsMessage == rhsMessage
            default:
                return false
            }
        }

        var icon: String {
            switch self {
            case .pending: return "circle"
            case .processing: return "arrow.triangle.2.circlepath"
            case .completed: return "checkmark.circle.fill"
            case .failed: return "exclamationmark.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .pending: return .secondary
            case .processing: return .accentColor
            case .completed: return .green
            case .failed: return .red
            }
        }
    }
}
