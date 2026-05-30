import SwiftUI

struct FileExpandButton: View {
    let isDirectory: Bool
    let isExpanded: Bool
    let onExpandedChange: (Bool) -> Void  // 状态改变时通知外部
    
    @State private var isHovering = false
    
    init(isDirectory: Bool, isExpanded: Bool = false, onExpandedChange: @escaping (Bool) -> Void) {
        self.isDirectory = isDirectory
        self.isExpanded = isExpanded
        self.onExpandedChange = onExpandedChange
    }
    
    var body: some View {
        Group {
            if isDirectory {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        onExpandedChange(!isExpanded)  // 通知外部状态变化
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundColor(isHovering ? .primary : .secondary)
                        .frame(width: 16)
                        .scaleEffect(isHovering ? 1.1 : 1.0)
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isHovering = hovering
                    }
                }
            } else {
                Spacer()
                    .frame(width: 16)
            }
        }
    }
} 
