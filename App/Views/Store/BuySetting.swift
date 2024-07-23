import OSLog
import StoreKit
import SwiftUI

struct BuySetting: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State var closeBtnHovered: Bool = false

    var body: some View {
        GroupBox {
            VStack {
                Text("订阅专业版").font(.title)

                featureView.padding()
                SubscriptionSetting().padding(.horizontal)
            }
            .padding(.top, 12)
        }.background(BackgroundView.type1.opacity(0.1))
    }

    private var featureView: some View {
        VStack(spacing: 2) {
            HStack {
                Text("♾️")
                    .font(.system(size: 18))
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    .padding(.trailing, 0)
                Text("软件功能全无限制")
            }
            HStack {
                Text("💗")
                    .font(.system(size: 18))
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    .padding(.trailing, 0)
                Text("支持我们持续开发")
            }
        }
    }

    // MARK: Footer

    private var footerView: some View {
        GroupBox {
            HStack {
                Spacer()
                Link("隐私政策", destination: URL(string: "https://www.kuaiyizhi.cn/privacy")!)
                Link("许可协议", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                Spacer()
            }
            .foregroundStyle(
                colorScheme == .light ?
                    .black.opacity(0.8) :
                    .white.opacity(0.8))
            .padding(.vertical, 12)
        }
        .padding(.horizontal)
        .font(.footnote)
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview("Buy") {
    BuyView()
        .environmentObject(StoreProvider())
        .frame(height: 800)
}
