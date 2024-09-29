import MagicKit
import OSLog
import StoreKit
import SwiftUI

struct BuySetting: View {
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

struct Feature: Identifiable {
    let id = UUID()
    let name: String
    let freeVersion: String
    let proVersion: String
}

struct Plan: Identifiable {
    let id = UUID()
    let name: String
    let price: String
    let period: String
    let features: [String: Any]
}

struct PlanView: View {
    let plan: Plan

    var body: some View {
        VStack {
            Text(plan.name)
                .font(.headline)
            Divider()

//            Text(plan.price)
//                .font(.system(size: 36, weight: .bold))
//            + Text(plan.period)
//                .font(.subheadline)

//            Button("Buy plan") {
//                // Handle purchase
//            }
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(plan.name == "Essential" ? Color.blue : Color.gray)
//            .foregroundColor(.white)
//            .cornerRadius(8)

            VStack(alignment: .leading, spacing: 10) {
                Text("Features")
                    .font(.headline)

                ForEach(Array(plan.features.keys.sorted()), id: \.self) { key in
                    HStack {
                        Text(key)
                        Spacer()
                        if let value = plan.features[key] as? Bool {
                            Image(systemName: value ? "checkmark" : "minus")
                        } else if let value = plan.features[key] as? String {
                            Text(value)
                        }
                    }
                }
            }
            .padding(.top)
        }
        .padding()
        .background(plan.name == "专业版本" ? Color.gray.opacity(0.2) : Color.clear)
        .cornerRadius(12)
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
