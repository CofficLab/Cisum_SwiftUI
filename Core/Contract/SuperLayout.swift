import SwiftUI
import Foundation

protocol SuperLayout: Identifiable {
    var id: String { get }
    var iconName: String { get }
    var icon: any View { get }
    var name: String { get }
    var description: String { get }
    var poster: any View { get }
    var layout: any View { get }
}

extension SuperLayout {
    var name: String {
        String(describing: type(of: self))
    }
}
