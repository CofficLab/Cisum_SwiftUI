import Foundation

struct Feature: Identifiable {
    let id = UUID()
    let name: String
    let freeVersion: String
    let proVersion: String
}
