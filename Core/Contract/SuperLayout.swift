import SwiftUI
import Foundation

protocol SuperLayout: Identifiable {
    var id: String { get }
    var iconName: String { get }
    var icon: any View { get }
    var title: String { get }
    var description: String { get }
    var poster: any View { get }
    var layout: any View { get }
}
