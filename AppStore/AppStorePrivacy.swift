import SwiftUI
import MagicKit
import MagicUI

/**
 * App Store - 隐私与尊重页面
 * 展示对用户的尊重：无需注册登录、无广告、无弹窗
 */
struct AppStorePrivacy: View {
    var body: some View {
        AppStoreHeroContainer(
            title: "尊重用户",
            subtitleTop: "无需注册，无需登录。",
            subtitleBottom: "没有广告，没有弹窗，只有纯净的音乐体验。"
        ) {
            VStack(spacing: 32) {
                // 特点卡片网格
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
            }
            .frame(width: Config.minWidth, height: 500)
            .background(.background)
            .magicRoundedLarge()
        }
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
