import AVFoundation
import Foundation
import SwiftUI

struct PlayList: Equatable, Identifiable {
    var id: String {
        title
    }

    var title: String = "[空白]"
}
