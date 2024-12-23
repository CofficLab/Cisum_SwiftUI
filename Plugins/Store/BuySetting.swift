import MagicKit
import OSLog
import StoreKit
import SwiftUI

struct BuySetting: View, SuperLog {
    static let emoji = "🛒"
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State var closeBtnHovered: Bool = false

    let features: [Feature] = [
        Feature(name: "文件数量", freeVersion: "最多 \(Config.maxAudioCount)", proVersion: "无限制"),
    ]

    let plans = [
        Plan(name: "基础版本", price: "0", period: "/month", features: [
            "iCloud 同步": true,
            "文件数量": "最多 \(Config.maxAudioCount)",
        ]),
        Plan(name: "专业版本", price: "$29", period: "/month", features: [
            "iCloud 同步": true,
            "文件数量": "无限制",
        ]),
    ]

    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 20) {
                ForEach(plans) { plan in
                    PlanView(plan: plan)
                }
            }
            .padding()
            .background(BackgroundView.type1.opacity(0.1))

            SubscriptionSetting()
                .padding()
                .background(BackgroundView.type1.opacity(0.1))
            
            RestoreView()
                .padding()
                .background(BackgroundView.type1.opacity(0.1))

            footerView
        }
    }

    // MARK: Footer

    private var footerView: some View {
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

        .font(.footnote)
        .background(BackgroundView.type1.opacity(0.1))
    }
}

#Preview("App") {
    AppPreview()
        .frame(height: 800)
}

#Preview("Buy") {
    BuySetting()
        .environmentObject(StoreProvider())
        .frame(height: 800)
}
