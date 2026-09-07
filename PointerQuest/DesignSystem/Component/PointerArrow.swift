import SwiftUI

/// "이 칸에 저장된 주소가 저 칸을 가리킨다"를 나타내는 화살표 (선 + 머리)
/// 표기 규칙은 `VISUAL_LANGUAGE.md` §3을 따르며, 그리드와 개념 카드 도식이 같은 표기를 쓰도록 이 뷰 하나로 모은다
struct PointerArrow: View {
  /// 가리키는 쪽(포인터 칸)의 중심
  let startPoint: CGPoint
  /// 가리켜지는 쪽 칸의 중심
  let endPoint: CGPoint

  var body: some View {
    // 화살표 각도 계산 (끝점이 시작점에서 어느 방향에 있는지)
    let angle = Angle(radians: atan2(
      endPoint.y - startPoint.y,
      endPoint.x - startPoint.x
    ))

    Group {
      // 1. 화살표 선
      Arrow(startPoint: startPoint, endPoint: endPoint)
        .stroke(
          Color(.main).opacity(0.6),
          style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
        )

      // 2. 화살표 머리 (삼각형)
      Triangle()
        .fill(Color(.main))
        .frame(width: 16, height: 16) // 적당한 화살표 크기
        .rotationEffect(angle)        // 선의 방향에 맞춰 회전
        .position(endPoint)
    }
  }
}

#Preview {
  PointerArrow(
    startPoint: .init(x: 40, y: 60),
    endPoint: .init(x: 160, y: 60)
  )
  .frame(width: 200, height: 120)
}
