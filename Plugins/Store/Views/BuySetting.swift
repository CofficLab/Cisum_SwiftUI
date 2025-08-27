import MagicCore

import OSLog
import StoreKit
import SwiftUI

struct BuySetting: View, SuperLog {
    nonisolated static let emoji = "🛒"
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.dismiss) private var dismiss
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
            // 添加关闭按钮
            HStack {
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                #if os(macOS)
                .onHover { hovering in
                    closeBtnHovered = hovering
                }
                .scaleEffect(closeBtnHovered ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: closeBtnHovered)
                #endif
                #if os(iOS)
                .scaleEffect(closeBtnHovered ? 0.9 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: closeBtnHovered)
                .onTapGesture {
                    closeBtnHovered = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        closeBtnHovered = false
                    }
                }
                #endif
            }
            .padding(.vertical, 2)
            
            HStack(alignment: .top, spacing: 20) {
                ForEach(plans) { plan in
                    PlanView(plan: plan)
                }
            }
            .padding()
            .background(MagicBackground.aurora.opacity(0.1))

            SubscriptionSetting()
                .padding()
                .background(MagicBackground.aurora.opacity(0.1))
            
            RestoreView()
                .padding()
                .background(MagicBackground.aurora.opacity(0.1))

            footerView
        }
        .padding()
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
        .background(MagicBackground.aurora.opacity(0.1))
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
