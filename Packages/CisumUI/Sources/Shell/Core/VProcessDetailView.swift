import SwiftUI
#if os(macOS)
struct VProcessDetailView: View {
    @State private var selectedPID = ""
    @State private var processDetails = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                TextField("输入进程PID", text: $selectedPID)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 100)
                
                Button("查看详情") {
                    if !selectedPID.isEmpty {
                        processDetails = ShellProcess.getProcessDetails(pid: selectedPID)
                    }
                }
                .disabled(selectedPID.isEmpty)
            }
            
            if !processDetails.isEmpty {
                ScrollView {
                    Text(processDetails)
                        .font(.caption)
                        .fontDesign(.monospaced)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 100)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
}
#endif
