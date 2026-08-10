import SwiftUI

/// 레슨 1 그리드 화면에 처음 진입했을 때 실사용 맥락을 보여주는 드래그 안내 오버레이
/// 소스 슬롯(포인터)에서 타겟 슬롯(값)으로 향하는 손동작 애니메이션 + 안내 말풍선을 그린다
struct GridInteractionHintOverlay: View {
  let sourceRect: CGRect
  let targetRect: CGRect
  let containerSize: CGSize
  let onDismiss: () -> Void
  
  @State private var isAnimating = false
  
  private var sourceCenter: CGPoint {
    return .init(x: sourceRect.midX, y: sourceRect.midY)
  }
  
  private var targetCenter: CGPoint {
    return .init(x: targetRect.midX, y: targetRect.midY)
  }
  
  var body: some View {
    ZStack {
      HandIcon
      
      CalloutBubble
        .frame(maxWidth: min(containerSize.width - 32, 280))
        .position(x: containerSize.width / 2, y: 28)
    }
  }
}

private extension GridInteractionHintOverlay {
  // 소스 -> 타겟을 오가며 드래그 동작을 암시하는 반복 애니메이션 아이콘
  // 터치 이벤트를 막지 않도록 hitTesting을 통과시킨다 (ArrowDrawLayer와 동일한 패턴)
  var HandIcon: some View {
    Image(systemName: "hand.draw.fill")
      .font(.title)
      .foregroundStyle(Color(.main))
      .shadow(radius: 3)
      .position(isAnimating ? targetCenter : sourceCenter)
      .animation(
        .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
        value: isAnimating
      )
      .allowsHitTesting(false)
      .onAppear { isAnimating = true }
  }
  
  var CalloutBubble: some View {
    HStack(alignment: .top, spacing: 8) {
      Text("이 슬롯을 드래그해서 저 주소 위에 놓아보세요")
        .font(.footnote)
        .foregroundStyle(.white)
        .fixedSize(horizontal: false, vertical: true)
      
      Button(action: onDismiss) {
        Image(systemName: "xmark.circle.fill")
          .foregroundStyle(.white.opacity(0.8))
      }
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color(.main))
    )
    .shadow(radius: 4)
  }
}

#Preview {
  GridInteractionHintOverlay(
    sourceRect: CGRect(x: 40, y: 300, width: 100, height: 100),
    targetRect: CGRect(x: 160, y: 100, width: 100, height: 100),
    containerSize: CGSize(width: 360, height: 420),
    onDismiss: {}
  )
}
