import SwiftUI

/// 포인터 화살표를 그리는 레이어
struct ArrowDrawLayer: View {
  @ObservedObject var vm: MemoryGridVM
  let slotFrames: [UUID: CGRect]
  
  var body: some View {
    Canvas { context, size in
      // 모든 포인터 슬롯을 순회하며 화살표를 그립니다.
      for slot in vm.slots where slot.type == .pointer {
        guard let targetAddr = slot.pointingTo,
              // Start: 포인터 슬롯의 위치
              let startRect = slotFrames[slot.id],
              // End: 타겟 슬롯의 위치 (주소로 찾음)
              let targetSlot = vm.slots.first(where: { $0.address == targetAddr }),
              let endRect = slotFrames[targetSlot.id]
        else { continue }
        
        // 각 사각형의 중심점 계산
        let startPoint = CGPoint(x: startRect.midX, y: startRect.midY)
        let endPoint = CGPoint(x: endRect.midX, y: endRect.midY)
        
        // 경로 그리기
        var path = Path()
        path.move(to: startPoint)
        
        // 곡선(Bezier Curve)으로 부드럽게 연결
        let control1 = CGPoint(
          x: startPoint.x,
          y: (startPoint.y + endPoint.y) / 2
        )
        
        let control2 = CGPoint(
          x: endPoint.x,
          y: (startPoint.y + endPoint.y) / 2
        )
        
        path.addCurve(to: endPoint, control1: control1, control2: control2)
        
        // 선 스타일 설정
        context.stroke(
          path,
          with: .color(.blue.opacity(0.6)), // 너무 진하지 않게 투명도 조절
          style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
        )
        
        // 화살표 머리 그리기 (원형)
        let arrowHead = Path(ellipseIn: CGRect(x: endPoint.x - 6, y: endPoint.y - 6, width: 12, height: 12))
        context.fill(arrowHead, with: .color(.blue))
      }
    }
    .allowsHitTesting(false) // 터치 이벤트를 막지 않도록 통과시킴
  }
}
