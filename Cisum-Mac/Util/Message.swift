import SwiftUI

struct MessageView: View {
    var message = ""
    
    var body: some View {
        ZStack {
            Color.green.opacity(0.5)
            
            Text(message)
                .font(.callout)
        }
        .cornerRadius(8)
        .padding(.horizontal, 40)
        .frame(height: 100)
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            BackgroundView()
            
            MessageView(message: "你好")
        }
    }
}
