import Foundation

struct Plan: Identifiable {
    let id = UUID()
    let name: String
    let price: String
    let period: String
    let features: [String: Any]
}
