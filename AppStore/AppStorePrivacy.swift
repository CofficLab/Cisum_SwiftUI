import MagicKit
import SwiftUI

/**
 * App Store - 隐私与尊重页面
 * 展示对用户的尊重：无需注册登录、无广告、无弹窗
 */
struct AppStorePrivacy: View {
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 120) {
                // 左侧：标题和副标题
                VStack(alignment: .leading, spacing: 40) {
                    Spacer()

                    Text("尊重用户")
                        .font(.system(size: 100, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("无需注册，无需登录。")
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)

                    Text("没有广告，没有弹窗，只有纯净的音乐体验。")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)

                    Spacer()
                }
                .frame(width: geo.size.width * 0.3)

                // 右侧：自定义卡片内容
                HStack(spacing: 24) {
                    PrivacyFeatureCard(
                        icon: "person.badge.plus",
                        title: "无需注册",
                        description: "打开即用",
                        color: .blue
                    )

                    PrivacyFeatureCard(
                        icon: "lock.shield",
                        title: "无需登录",
                        description: "保护隐私",
                        color: .green
                    )

                    PrivacyFeatureCard(
                        icon: "nosign",
                        title: "没有广告",
                        description: "纯净体验",
                        color: .orange
                    )

                    PrivacyFeatureCard(
                        icon: "speaker.wave.3",
                        title: "没有弹窗",
                        description: "专注音乐",
                        color: .purple
                    )
                }
                .frame(width: Config.minWidth, height: 500)
                .background(.background)
                .magicRoundedLarge()
            }
            .padding(.horizontal, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .withBackgroundDecorations()
        .background(LinearGradient.pastel)
    }
}

// MARK: - Privacy Feature Card

struct PrivacyFeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        VStack(spacing: 16) {
            // 图标
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(color)

            // 文字
            VStack(spacing: 6) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .padding(.horizontal, 20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: color.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Preview

#Preview("App Store Privacy") {
    AppStorePrivacy()
        .inMagicContainer(.macBook13, scale: 0.4)
}
