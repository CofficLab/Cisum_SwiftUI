import SwiftUI

struct Operator: View {
    var text: String
    var action: (() -> Void) = {
        print("clicked")
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(text)
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .overlay(
                    Rectangle()
                        .fill(Color.black.opacity(0.3))
                        .frame(height: 30)
                        .cornerRadius(8)).padding(.horizontal, 8)
        }
        .buttonStyle(.plain)
    }
}
