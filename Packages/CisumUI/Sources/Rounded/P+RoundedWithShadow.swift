import SwiftUI

/// 带阴影的圆角预览
struct RoundedWithShadowPreview: View {
    var body: some View {
        VStack(spacing: 15) {
            Text("Rounded with Shadow")
                .font(.title2)
                .fontWeight(.semibold)

            Group {
                Text("XS")
                    .foregroundColor(.white)
                    .padding()
                    .infiniteWidth()
                    .background(Color.blue)
                    .roundedSmall()
                    .shadowSm()

                Text("MD")
                    .foregroundColor(.white)
                    .padding()
                    .infiniteWidth()
                    .background(Color.green)
                    .roundedMedium()
                    .shadowMd()
            }

            Group {
                Text("LG")
                    .foregroundColor(.white)
                    .padding()
                    .infiniteWidth()
                    .background(Color.orange)
                    .roundedLarge()
                    .shadowLg()

                Text("XL")
                    .foregroundColor(.white)
                    .padding()
                    .infiniteWidth()
                    .background(Color.purple)
                    .roundedExtraLarge()
                    .shadowXl()
            }
        }
        .padding()
        .infinite()
        .roundedMedium()
    }
}

#if DEBUG
    #Preview("Rounded with Shadow") {
        RoundedWithShadowPreview()
            .frame(height: 700)
    }
#endif
