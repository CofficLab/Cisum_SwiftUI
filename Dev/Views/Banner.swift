import SwiftUI

struct Banner: View {
    var title: String
    var subTitle: String
    var badges: [String]
    var inScreen: Bool = true
    var device: Device
    var onMessage: (_ message: String) -> Void
    
    @State private var imageURL: URL? = nil

    private var image: Image {
        if let url = imageURL {
            return Image(nsImage: NSImage(data: try! Data(contentsOf: url))!)
        }

        return Image("Snapshot-1")
    }
    
    @MainActor private var imageSize: String {
        "\(ImageHelper.getViewWidth(content)) X \(ImageHelper.getViewHeigth(content))"
    }

    private var content: some View {
        ZStack {
            switch device.type {
            case .Mac:
                forMac()
            case .iPhone:
                foriPhone()
            case .iPad:
                foriPad()
            }
        }
        .foregroundStyle(.white)
        .frame(width: device.width, height: device.height)
        .background(BackgroundView.type2A)
    }

    var body: some View {
        GeometryReader { geo in
            HStack {
                ImageHelper.makeImage(content)
                    .resizable()
                    .scaledToFit()
                    .overlay { ViewHelper.dashedBorder }
                    .padding(.all, 20)
                    .toolbar {
                        Button("换图") {
                            let panel = NSOpenPanel()
                            panel.allowsMultipleSelection = false
                            panel.canChooseDirectories = false
                            if panel.runModal() == .OK, let url = panel.url {
                                self.imageURL = url
                            }
                        }
                        
                        Button("截图 \(imageSize)", action: {
                            onMessage(ImageHelper.snapshot(content))
                        })
                    }.frame(width: geo.size.width/1.5)
                
                BackgroundView.type1.padding(.vertical, 10)
            }
        }
    }

    // MARK: 针对 iPad 的布局

    private func foriPad() -> some View {
        VStack(spacing: 0, content: {
            getTitle().frame(height: device.height / 3)

            Spacer()

            HStack {
                Spacer()
                getBadges()
                Spacer()
                getContent().frame(width: device.width * 0.6)
                Spacer()
            }

            Spacer()
        })
    }

    // MARK: 针对 iPhone 的布局

    private func foriPhone() -> some View {
        VStack(spacing: 0, content: {
            getTitle().frame(height: device.height / 5)

            HStack {
                Spacer()
                getBadges()
                Spacer()
                getContent()
                Spacer()
            }

            Spacer()
        })
    }

    // MARK: 针对 Mac 的布局

    private func forMac() -> some View {
        HStack(spacing: 20) {
            VStack(spacing: 0, content: {
                getTitle().frame(height: device.height / 3)
                getBadges().background(.red.opacity(0.0))
                Spacer()
            })
            .background(.red.opacity(0.0)).frame(width: device.width / 3)

            getContent()
                .padding(.trailing, 100)
                .frame(width: device.width / 3 * 2)
                .background(.green.opacity(0.0))
        }
    }

    // MARK: 右侧的视图

    private func getContent() -> some View {
        ZStack {
            if inScreen {
                Screen(device: device, content: {
                    switch device.type {
                    case .Mac:
                        image.resizable()
                            .scaledToFit()
                    case .iPhone:
                        image.resizable()
                            .scaledToFit()
                    case .iPad:
                        image.resizable()
                            .scaledToFit()
                    }
                })
            } else {
                switch device.type {
                case .Mac:
                    image.resizable()
                        .scaledToFit()
                case .iPhone:
                    image.resizable()
                        .scaledToFit()
                case .iPad:
                    image.resizable()
                        .scaledToFit()
                }
            }
        }
    }

    // MARK: 主标题与副标题

    private func getTitle() -> some View {
        VStack {
            Text(title).font(.system(size: 200))
                .padding(.bottom, 60)
                .padding(.top, 300)
            Text(subTitle).font(.system(size: 100))
                .padding(.bottom, 60)
        }
    }

    // MARK: 描述特性的小块

    private func getBadges() -> some View {
        Badges(device: device, badges: badges)
    }
}

#Preview {
    SmartContainer {
        Banner(title: "1", subTitle: "2", badges: [], device: .MacBook, onMessage: {message in 
            
        })
    }
}
