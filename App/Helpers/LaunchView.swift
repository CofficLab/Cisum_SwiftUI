import SwiftUI

struct LanuchView: View {
    var errorMessage: String? = nil

    var body: some View {
        VStack {
            if errorMessage == nil {
                CardView(background: BackgroundView.type2) {
                    VStack {
                        Spacer()
                        
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()

                        Text("正在加载").font(.title).foregroundStyle(.white)
                        
                        Spacer()
                    }
                }.frame(width: 150, height: 150)
            } else {
                Text(errorMessage!)
            }
        }
    }
}

#Preview {
    VStack {
        LanuchView()

        Divider()

        LanuchView(errorMessage: "启动出现错误")
    }
}
