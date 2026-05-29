import MagicPlayMan
import SwiftUI

public struct LikeToggleButtonView: View {
    public static var order: Int { 21 }

    @EnvironmentObject var man: MagicPlayMan

    public init() {}

    public var body: some View {
        Group {
            if man.asset == nil {
                EmptyView()
            } else {
                man.makeLikeButtonView(size: 24)
            }
        }
    }
}
