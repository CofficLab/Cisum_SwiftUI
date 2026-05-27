import SwiftUI

/// 复杂内容卡片预览
struct CardComplexPreview: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("复杂内容卡片")
                .font(.headline)
                .withDivider(spacing: 10)

            HStack {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.blue)
                VStack(alignment: .leading) {
                    Text("用户名")
                        .font(.headline)
                    Text("用户描述")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .inCardUltraThin()

            VStack(alignment: .leading, spacing: 8) {
                Text("文章标题")
                    .font(.headline)
                Text("这是一段较长的文章描述，用来展示卡片中多行内容的显示效果。")
                    .font(.body)
                    .foregroundColor(.secondary)
                HStack {
                    Image(systemName: "hand.thumbsup.fill")
                    Text("点赞")
                    Spacer()
                    Image(systemName: "bubble.right.fill")
                    Text("评论")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .inCard(gradient: [.blue, .purple])
            .foregroundColor(.white)
        }
        .padding()
        .infinite()
        .inScrollView()
    }
}

#if DEBUG
    #Preview("Card Complex") {
        CardComplexPreview()
            .frame(height: 600)
            .frame(width: 500)
    }
#endif
