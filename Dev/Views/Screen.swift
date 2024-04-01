import SwiftUI
import UniformTypeIdentifiers

struct Screen<Content>: View where Content: View {
    private let content: Content

    var device: Device = .iMac

    // 图片的尺寸
    var width: CGFloat {
        switch device {
        case .iMac:
            return 5640
        case .MacBook:
            return 3200
        case .iPhoneBig, .iPhoneSmall:
            return 1370
        case .iPad:
            return 2550
        }
    }

    var height: CGFloat {
        switch device {
        case .iMac:
            return 4540
        case .MacBook:
            return 2100
        case .iPhoneBig, .iPhoneSmall:
            return 2732
        case .iPad:
            return 2000
        }
    }

    // 图片里的屏幕的尺寸
    var screenWidth: CGFloat {
        switch device {
        case .iMac:
            return 5130
        case .MacBook:
            return 2550
        case .iPhoneBig, .iPhoneSmall:
            return 1178
        case .iPad:
            return 2275
        }
    }

    var screenHeight: CGFloat {
        switch device {
        case .iMac:
            return 2890
        case .MacBook:
            return 1650
        case .iPhoneSmall, .iPhoneBig:
            return 2700
        case .iPad:
            return 1500
        }
    }

    // 图片里的屏幕不在正中间，需要偏移，这个值是试出来的
    var screenOffset: CGFloat {
        switch device {
        case .iMac:
            return -580
        case .MacBook:
            return 0
        case .iPhoneBig, .iPhoneSmall:
            return 0
        case .iPad:
            return 0
        }
    }

    init(device: Device = .iMac, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.device = device
    }

    var body: some View {
        fullView
    }

    var fullView: some View {
        GeometryReader { geo in
            VStack {
                if geo.size.height > height / getScale(geo) {
                    Spacer()
                }

                HStack {
                    if geo.size.width > width / getScale(geo) {
                        Spacer()
                    }
                    ZStack {
                        content
                            .frame(width: screenWidth / getScale(geo), height: screenHeight / getScale(geo))
                            // .border(.red)
//                             .background(.red)
                            .offset(x: 0, y: screenOffset / getScale(geo))

                        getDeviceImage()
                        // .border(.yellow)
                    }
                    .frame(width: width / getScale(geo), height: height / getScale(geo))
                    // .border(.red)

                    if geo.size.width > width / getScale(geo) {
                        Spacer()
                    }
                }

                if geo.size.height > height / getScale(geo) {
                    Spacer()
                }
            }
        }
    }

    private func getScale(_ geo: GeometryProxy) -> CGFloat {
        max(width / geo.size.width, height / geo.size.height)
    }

    private func getDeviceImage() -> some View {
        return ZStack {
            switch device {
            case .MacBook:
                Image("MacBook Air 13\" - 4th Gen - Midnight")
                    .resizable()
                    .scaledToFit()
            case .iMac:
                Image("iMac 27\" - Silver")
                    .resizable()
                    .scaledToFit()
            case .iPad:
                Image("iPad mini - Starlight - Landscape")
                    .resizable()
                    .scaledToFit()
            case .iPhoneBig, .iPhoneSmall:
                Image("iPhone 14 - Midnight - Portrait")
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}
