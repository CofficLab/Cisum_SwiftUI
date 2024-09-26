import SwiftUI

protocol SuperPlugin {
    var label: String { get }
    var layout: AnyView { get }
}
