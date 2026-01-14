import Foundation

@MainActor
final class MemoryGridVM: ObservableObject {
  /// 메모리 Cells
  @Published private(set) var slots = [MemorySlot]()
  
  /// 현재 실행된 동작을 C 코드로 보여주는 로그
  @Published var codeLog = "// The executed operation is represented as C language code."
  
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
    highlightSlot(for: index)
  }
  
  /// 드래그 앤 드롭 작업이 완료되었을 때 호출
  /// - Parameters:
  ///   - sourceAddress: 드래그를 시작한 슬롯(포인터가 될 슬롯)의 주소
  ///   - destinationAddress: 드롭된 위치의 슬롯(가리킴을 당할 대상)의 주소
  func handleDrop(sourceAddress: String, destinationAddress: String) {
    // 1. 드래그한 슬롯(Source)의 인덱스를 찾기
    guard let sourceIndex = slots.firstIndex(
      where: { $0.address == sourceAddress }
    ) else {
      return
    }
    
    // 2. 드래그한 슬롯을 pointer 타입으로 변경하고, 대상의 주소를 저장
    // C 언어의 `source = &destination;`과 같은 논리
    slots[sourceIndex].type = .pointer
    slots[sourceIndex].pointingTo = destinationAddress
    
    // 타겟 슬롯 인덱스 찾기
    if let targetIndex = slots.firstIndex(
      where: { $0.address == destinationAddress }
    ) {
        // 타겟이 비어있다면 값 초기화 (Auto-Initialization)
        if slots[targetIndex].type == .empty {
            let randomValue = Int.random(in: 1...99)
            slots[targetIndex].type = .value
            slots[targetIndex].value = randomValue
            
            // 초기화된 사실을 로그에 자연스럽게 표현
            codeLog = "int target = \(randomValue); // (자동 초기화)\nint *p = &target;"
            
            // 시각적 혼란을 줄이기 위해 타겟에도 하이라이트 효과
            highlightSlot(for: targetIndex)
        } else {
    codeLog = "int *p = \(destinationAddress);"
        }
    } else {
        codeLog = "int *p = \(destinationAddress);"
    }
    
    // 3. 시각적 피드백: 포인터 슬롯 강조
    highlightSlot(for: sourceIndex)
    
    print("연결 완료: \(sourceAddress) -> \(destinationAddress)")
  }

  /// 포인터를 역참조(Dereference)하여 대상 슬롯을 찾고 시각적 피드백 제공
  /// - Parameter pointerAddr: 역참조할 포인터 슬롯의 주소
  func dereference(pointerAddr: String) {
    // 1. 역참조를 시도하는 슬롯 검색
    guard let pointerIndex = slots.firstIndex(where: { $0.address == pointerAddr }) else { return }
    let pointerSlot = slots[pointerIndex]

    // 2. 해당 슬롯이 포인터 타입인지 확인
    guard pointerSlot.type == .pointer,
          let targetAddr = pointerSlot.pointingTo,
          let targetIndex = slots.firstIndex(where: { $0.address == targetAddr })
    else {
      // 포인터가 아니거나 가리키는 대상이 없는 경우 (추후 에러 피드백 추가 가능)
      print("역참조 실패: 유효한 포인터가 아닙니다.")
      codeLog = "// Error: 유효하지 않은 포인터입니다."
      return
    }

    // 로그 업데이트
    if let value = slots[targetIndex].value {
        codeLog = "printf(\"%d\", *p); // 값: \(value)"
    } else {
        codeLog = "// 역참조 성공! (값 없음)"
    }

    // 3. 대상 슬롯 하이라이트 (포인터를 따라간 효과)
    print("역참조 성공! \(pointerAddr) -> \(targetAddr) (Value: \(slots[targetIndex].value ?? 0))")
    highlightSlot(for: targetIndex)
  }
  
  /// slot 변경 시 일시적인 하이라이트 효과로 사용자에게 알림
  private func highlightSlot(for index: Int) {
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
    
    // 초기 더미데이터 설정
    
    slots[0].value = 42
    slots[0].type = .value
    
    slots[5].type = .pointer
    slots[5].pointingTo = "0x7000"
  }
}
