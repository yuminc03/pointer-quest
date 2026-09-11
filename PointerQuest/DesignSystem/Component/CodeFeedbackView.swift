import SwiftUI

/// 생성된 코드를 Terminal 스타일로 보여주는 컴포넌트
struct CodeFeedbackView: View {
  let code: LocalizedStringResource
  
  var body: some View {
    HStack(alignment: .firstTextBaseline) {
      Image(systemName: "chevron.right")
        .font(.body)
        .fontWeight(.bold)
        .foregroundStyle(.white)
      
      // String(localized:)로 먼저 리졸브한 뒤 직접 채색해, Text가 `*`/`**`를
      // 마크다운 강조 기호로 오인식해 텍스트가 사라지는 문제를 근본적으로 피한다
      Text(CCodeHighlighter.highlight(String(localized: code)))
        .font(.system(.body, design: .monospaced))
        .foregroundStyle(.white)
        .fixedSize(horizontal: false, vertical: true)

      Spacer()
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color(white: 0.15))
    )
    .shadow(radius: 5)
  }
}

#Preview {
  CodeFeedbackView(code: "int *p = &a;")
    .padding()
}
