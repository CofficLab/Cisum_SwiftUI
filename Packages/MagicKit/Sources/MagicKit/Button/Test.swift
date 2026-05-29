import SwiftUI

struct PopoverExample: View {
    @State private var isShowingPopover = false


    var body: some View {
        Button("Show Popover") {
            self.isShowingPopover = true
        }
        .popover(
            isPresented: $isShowingPopover, arrowEdge: .bottom
        ) {
            Text("Popover Content")
                .padding()
        }
    }
}

struct TestView: View {
    @State private var showingPopover = false
    var body: some View {
        Text("EEEE")
            .onTapGesture {
                // 只在 popover 未显示时触发
                guard !showingPopover else { return }
                showingPopover = true
            }
            .popover(isPresented: $showingPopover, arrowEdge: .top) {
                Text("5555")
            }.onAppear {
                // 确保初始状态正确设置
                if showingPopover {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.showingPopover = true
                    }
                }
            }
    }
}

#if DEBUG
#Preview() {
    PopoverExample()
        .frame(height: 500)
        .frame(width: 500)
}
#endif
