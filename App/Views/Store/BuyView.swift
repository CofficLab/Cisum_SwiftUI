import OSLog
import StoreKit
import SwiftUI

struct BuyView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State var closeBtnHovered: Bool = false

    var onClose: () -> Void = {
        print("点击了关闭按钮")
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    Text("帮助我们做的更好").font(.title)

                    featureView
                        .frame(width: 300)
                        .padding()
                    
                    MySubscription().padding()
                    AllSubscriptions().padding(.horizontal)
//                    NonRenewables().padding(.horizontal)
                    footerView
                }
                .padding(.top, 48)
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var headerView: some View {
        VStack {
            HStack {
                //                            Button("恢复购买", action: {
                //                                Task {
                //                                    // This call displays a system prompt that asks users to authenticate with their App Store credentials.
                //                                    // Call this function only in response to an explicit user action, such as tapping a button.
                //                                    try? await AppStore.sync()
                //                                }
                //                            })

                Button(action: {
                    onClose()
                }, label: {
                    Label("关闭", systemImage: "xmark.circle")
                        .labelStyle(.iconOnly)
                        .font(.title)
                        .foregroundStyle(.red.opacity(0.5))
                        .scaleEffect(closeBtnHovered ? 1.1 : 1)
                })
                .buttonStyle(.plain)
                .onHover(perform: { hovering in
                    withAnimation {
                        closeBtnHovered = hovering
                    }
                })

                Spacer()
            }
            .padding(.vertical, 2)
            .padding(.horizontal, 2)
            Spacer()
        }
    }
    
    private var featureView: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("♾️")
                    .font(.system(size: 30))
                    .frame(width: 35, height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    .padding(.trailing, 5)
                Text("不断优化用户体验")
            }
            Divider()
            HStack {
                Text("💗")
                    .font(.system(size: 30))
                    .frame(width: 35, height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    .padding(.trailing, 5)
                Text("支持我们的持续开发")
            }
            Divider()
            HStack {
                Text("👑")
                    .font(.system(size: 30))
                    .frame(width: 35, height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    .padding(.trailing, 5)
                Text("更多高级功能")
            }
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
    }
}

#Preview {
    AppPreview()
        .frame(height: 800)
}

#Preview {
    BuyView()
        .environmentObject(StoreManager())
        .frame(height: 800)
}
