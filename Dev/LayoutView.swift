import SwiftUI

struct LayoutView: View {
    var minWidth = AppConfig.minWidth
    var minHeight = AppConfig.minHeight
    var width: CGFloat?
    var height: CGFloat?
    var device: Device?

    var body: some View {
        ZStack {
            if let width = width, width < minWidth {
                Text("宽度至少 \(minWidth)")
                    .padding()
                    .foregroundStyle(.yellow)
            } else if let device = device {
                // 针对特定设备
                makeItemForDevice(device)
            } else if let width = width, height == nil {
                // 固定宽度，多个高度
                makeItemForManyHeights(width: width)
            } else if let width = width, let height = height {
                // 宽度、高度都固定
                makeItem(width: width, height: height)
            } else {
                // 默认
                forManyDevices()
            }
        }.modelContainer(AppConfig.getContainer())
    }

    func forManyDevices() -> some View {
        let devices: [Device] = [
            .iMac,
//            .MacBook,
            .iPad_mini,
//            .iPhone_15,
//            .iPhoneBig,
//            .iPhoneSmall,
        ]

        return
            TabView(content: {
                ForEach(devices, id: \.self) { device in
                    makeItem(width: device.width, height: device.height)
                        .id("\(device.rawValue)")
                        .tabItem { Label("\(device.description)", systemImage: "apple") }
                }
            })
    }

    func makeItemForManyHeights(width: CGFloat) -> some View {
        let heights: [CGFloat] = [
            minHeight + 0,
            minHeight + 100,
            minHeight + 200,
            minHeight + 300,
            minHeight + 400,
            minHeight + 500,
            minHeight + 600,
            minHeight + 700,
            minHeight + 800,
            minHeight + 900,
            minHeight + 1000,
        ]

        return ScrollView {
            Spacer(minLength: 20)
            ForEach(heights, id: \.self) { height in
                makeItem(width: width, height: height)
                    .frame(width: width, height: height)
                Spacer(minLength: 30)
                Divider()
            }

            Spacer()
        }
        .modelContainer(AppConfig.getContainer())
        .frame(width: width + 100)
        .frame(height: 800)
    }

    func makeItemForDevice(_ device: Device) -> some View {
        makeItem(width: device.width, height: device.height)
    }

    func makeItem(width: CGFloat, height: CGFloat) -> some View {
        GeometryReader { geo in
            ZStack {
                ZStack {
                    RootView {
                        ContentView()
                    }
                    .frame(width: width)
                    .frame(height: height)

                    VStack {
                        GroupBox {
                            Text("\(Int(width)) x \(Int(height))")
                            Text("\(Int(geo.size.width)) x \(Int(geo.size.height))")
                        }
                        Spacer()
                    }
                    .foregroundStyle(.yellow)
                    .font(.system(size: min(height / 10, width/6)))
                    .opacity(0.8)
                }.scaleEffect(min(geo.size.width / width, geo.size.height / height))
            }.frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

#Preview("Layout") {
    LayoutView()
}

#Preview("iPad") {
    LayoutView(device: .iPad_mini)
}

#Preview("iMac") {
    LayoutView(device: .iMac)
}

#Preview("iPhone SE") {
    LayoutView(device: .iPhone_SE)
}

#Preview("iPhone 15") {
    LayoutView(device: .iPhone_15)
}

#Preview("350") {
    LayoutView(width: 350)
}

#Preview("400") {
    LayoutView(width: 400)
}

#Preview("500") {
    LayoutView(width: 500)
}
