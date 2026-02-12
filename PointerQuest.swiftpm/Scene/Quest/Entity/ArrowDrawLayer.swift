import SwiftUI

/// 포인터 화살표를 그리는 레이어
struct ArrowDrawLayer: View {
  @ObservedObject var vm: MemoryGridVM
  let slotFrames: [UUID: CGRect]
  
  var body: some View {
    ZStack {
      // 모든 포인터 슬롯을 순회하며 화살표를 그립니다.
      ForEach(vm.slots) { slot in
        if slot.type == .pointer,
           let targetAddr = slot.pointingTo,
           let startRect = slotFrames[slot.id],
           let targetSlot = vm.slots.first(where: { $0.address == targetAddr }),
           let endRect = slotFrames[targetSlot.id]
        {
          // 각 사각형의 중심점 계산
          let startPoint = CGPoint(x: startRect.midX, y: startRect.midY)
          let endPoint = CGPoint(x: endRect.midX, y: endRect.midY)
          
          // 화살표 각도 계산 (끝점이 시작점에서 어느 방향에 있는지)
          let angle = Angle(radians: atan2(
            endPoint.y - startPoint.y,
            endPoint.x - startPoint.x
          ))
          
          Group {
            // 1. 화살표 선 (곡선)
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
          // 애니메이션 적용: 좌표(startPoint, endPoint)가 바뀔 때 부드럽게 이동
          .animation(
            .spring(response: 0.5, dampingFraction: 0.7),
            value: startPoint
          )
          .animation(
            .spring(response: 0.5, dampingFraction: 0.7),
            value: endPoint
          )
        }
      }
    }
    .allowsHitTesting(false) // 터치 이벤트를 막지 않도록 통과시킴
  }
}
