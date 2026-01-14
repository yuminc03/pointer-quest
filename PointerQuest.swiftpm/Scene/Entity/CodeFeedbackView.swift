import SwiftUI

/// 생성된 코드를 Terminal 스타일로 보여주는 컴포넌트
struct CodeFeedbackView: View {
  let code: String
  
  var body: some View {
    HStack(alignment: .firstTextBaseline) {
      Image(systemName: "chevron.right")
        .font(.body)
        .fontWeight(.bold)
        .foregroundStyle(.green)
      
      Text(code)
        .font(.system(.body, design: .monospaced))
        .foregroundStyle(.white)
      
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
