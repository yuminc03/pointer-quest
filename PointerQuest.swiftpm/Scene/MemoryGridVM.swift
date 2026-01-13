import Foundation

@MainActor
final class MemoryGridVM: ObservableObject {
  /// 메모리 Cells
  @Published private(set) var slots = [MemorySlot]()
  
  init() {
    initializeMemory()
  }
  
  /// 포인터 변수의 대상(pointingTo)을 업데이트
  /// - Parameters:
  ///   - sourceAddr: 포인터 역할을 할 슬롯의 주소
  ///   - targetAddr: 가리키게 될 대상 슬롯의 주소
  func updatePointer(
    from sourceAddr: String,
    to targetAddr: String
  ) {
    guard let index = slots.firstIndex(
      where: { $0.address == sourceAddr }
    ) else {
      return
    }
    
    slots[index].type = .pointer
    slots[index].pointingTo = targetAddr
    
    // 하이라이트 효과
    highlightSlot(index: index)
  }
  
  /// slot 변경 시 일시적인 하이라이트 효과로 사용자에게 알림
  private func highlightSlot(index: Int) {
    slots[index].isHighlighted = true
    
    // 1초 후에 하이라이트 해제
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      self.slots[index].isHighlighted = false
    }
  }
  
  /// 4 X 4 그리드 형태 가상 메모리 주소를 생성
  private func initializeMemory() {
    slots = (0 ..< 16).map {
      MemorySlot(
        address: String(format: "0x%04X", 0x7000 + ($0 * 4)),
        value: nil,
        type: .empty
      )
    }
    
    print(slots)
    
    // 초기 더미데이터 설정
    
    slots[0].value = 42
    slots[0].type = .value
    
    slots[5].type = .pointer
    slots[5].pointingTo = "0x7000"
  }
}
