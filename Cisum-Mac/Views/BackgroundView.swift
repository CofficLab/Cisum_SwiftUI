import SwiftUI

struct BackgroundView: View {
    var body: some View {
        GeometryReader { geo in
            Image("wave")
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height + 200)
                .ignoresSafeArea()
                .blur(radius: 20)
        }
    }
}

struct BackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundView()
    }
}
