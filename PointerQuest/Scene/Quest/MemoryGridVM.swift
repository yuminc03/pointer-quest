import Foundation

@MainActor
final class MemoryGridVM: ObservableObject {
  /// 메모리 Cells
  @Published private(set) var slots = [MemorySlot]()
  /// 현재 실행된 동작을 C 코드로 보여주는 로그
  @Published var codeLog = "// The executed operation is represented as C language code."
  /// 현재 진행 중인 레슨
  @Published private(set) var currentLesson: Lesson
  /// 미션 성공 여부
  @Published var isSuccess = false

  init(lesson: Lesson = LessonData.lessons[0]) {
    self.currentLesson = lesson
    self.setupLevel(level: lesson)
  }

  /// 현재 레슨 상태 초기화
  func reset() {
    setupLevel(level: currentLesson)
  }
  
  /// 슬롯 탭 처리
  func handleTap(_ slot: MemorySlot) {
    print("클릭된 메모리 주소: \(slot.address)")
    
    // Level 2: 잠긴 슬롯 탭 시 에러 피드백
    if slot.isLocked {
      codeLog = "// Error: Access Denied! Memory is locked."
      if let index = slots.firstIndex(where: { $0.id == slot.id }) {
        triggerError(for: index)
      }
      return
    }
    
    // 1. 포인터인 경우 (어딘가를 가리키고 있음)
    if let targetAddress = slot.pointingTo,
       let targetIndex = slots.firstIndex(where: { $0.address == targetAddress })
    {
      
      let targetSlot = slots[targetIndex]
      
      // Case A: 가리킨 곳에 값이 있는 경우 (일반 포인터)
      if let targetValue = targetSlot.value {
        codeLog = """
        int target = \(targetValue); // Value at \(targetAddress)
        int *p = &target; // This slot(\(slot.address)) points to target
        """
      }
      // Case B: 가리킨 곳도 포인터인 경우 (이중 포인터)
      else if targetSlot.type == .pointer {
        // ptr1이 가리키는 최종 대상 찾기
        var explicitLog = ""
        
        if let ultimateAddr = targetSlot.pointingTo,
           let ultimateIndex = slots.firstIndex(where: { $0.address == ultimateAddr }),
           let ultimateValue = slots[ultimateIndex].value {
          
          explicitLog = "int value = \(ultimateValue); // Value at \(ultimateAddr)\n"
          + "int *ptr1 = &value; // Ptr1 points to value\n"
        } else {
          // 최종 대상이 없거나 값이 없는 경우 (단순 주소 표기)
          explicitLog = "int *ptr1 = \(targetSlot.pointingTo ?? "NULL"); // \(targetAddress)\n"
        }
        
        codeLog = """
        \(explicitLog)int **ptr2 = &ptr1; // Double Pointer (This slot points to ptr1)
        """
      }
      // Case C: 가리킨 곳이 비어있는 경우
      else {
        codeLog = """
        int unknown; // Variable at \(targetAddress) is uninitialized
        int *p = &unknown; 
        // Warning: Dereferencing 'p' yields garbage value.
        """
      }
      
      // 시각적 효과: 가리키는 대상 깜빡임
      highlightSlot(for: targetIndex)
      return
    }
    
    // 2. 값을 가진 변수인 경우
    if let value = slot.value {
      codeLog = "int val = \(value); // Value at \(slot.address)"
    }
    // 3. 빈 슬롯인 경우
    else {
      codeLog = "// Address: \(slot.address)"
    }
  }
  
  /// 드래그 앤 드롭 작업이 완료되었을 때 호출
  /// - Parameters:
  ///   - sourceAddress: 드래그를 시작한 슬롯(포인터가 될 슬롯)의 주소
  ///   - destinationAddress: 드롭된 위치의 슬롯(가리킴을 당할 대상)의 주소
  func handleDrop(sourceAddress: String, destinationAddress: String) {
    // 1. 드래그한 슬롯(Source)의 인덱스를 찾기
    // 자기 자신을 가리키는 것은 방지 (Self-reference Prevention)
    if sourceAddress == destinationAddress {
      codeLog = "// Error: Cannot point to itself (Self-Reference)."
      if let sourceIndex = slots.firstIndex(where: { $0.address == sourceAddress }) {
        triggerError(for: sourceIndex)
      }
      return
    }
    
    guard let sourceIndex = slots.firstIndex(
      where: { $0.address == sourceAddress }
    ) else {
      return
    }
    
    // 잠긴 슬롯 직접 연결 시도 방지 (Security Check)
    if let targetIndex = slots.firstIndex(where: { $0.address == destinationAddress }),
       slots[targetIndex].isLocked
    {
      codeLog = "// Error: Security Violation! Direct access is not allowed. (Access Denied)"
      triggerError(for: targetIndex)
      return
    }
    
    // 2. 드래그한 슬롯을 pointer 타입으로 변경하고, 대상의 주소를 저장
    // C 언어의 `source = &destination;`과 같은 논리
    slots[sourceIndex].type = .pointer
    slots[sourceIndex].value = nil // 기존 값이 남아있으면 UI에서 포인터 주소가 가려짐
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
        codeLog = "int target = \(randomValue);\nint *p = &target;"
        
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
    
    // 성공 조건 검사
    checkSuccess()
    
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
      // 포인터가 아니거나 가리키는 대상이 없는 경우
      print("역참조 실패: 유효한 포인터가 아닙니다.")
      codeLog = "// Error: Invalid pointer."
      triggerError(for: pointerIndex)
      return
    }
    
    // 로그 업데이트
    let targetSlot = slots[targetIndex]
    if let value = targetSlot.value {
      codeLog = "printf(\"%d\", *p); // Value: \(value)"
    } else if targetSlot.type == .pointer {
      // 이중 포인터인 경우 더 명확한 로그 제공
      codeLog = "printf(\"%p\", *p); // Double Pointer (Target is also a pointer)"
    } else {
      codeLog = "printf(\"%p\", *p); // Address: \(targetAddr)"
    }
    
    // 3. 대상 슬롯 하이라이트 (포인터를 따라간 효과)
    print("역참조 성공! \(pointerAddr) -> \(targetAddr) (Value: \(slots[targetIndex].value ?? 0))")
    highlightSlot(for: targetIndex)
    
    // Level 2: 잠금 해제 로직 (제거됨 - 징검다리 포인터 미션으로 변경)
    // if slots[targetIndex].isLocked { ... } -> 삭제
  }
  
  /// 에러 발생 시 시각적 피드백 (흔들림 + 빨간색)
  private func triggerError(for index: Int) {
    slots[index].isError = true
    
    // 0.5초(애니메이션 시간) 후 해제
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.slots[index].isError = false
    }
  }
  
  /// slot 변경 시 일시적인 하이라이트 효과로 사용자에게 알림
  private func highlightSlot(for index: Int) {
    slots[index].isHighlighted = true
    
    // 1초 후에 하이라이트 해제
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      self.slots[index].isHighlighted = false
    }
  }
  
  /// 4 X 4 그리드 형태 가상 메모리 주소를 생성 및 레벨별 초기화
  private func setupLevel(level: Lesson) {
    // 1. 기본 빈 슬롯 16개 생성
    slots = (0 ..< 16).map {
      MemorySlot(
        address: String(format: "0x%04X", 0x7000 + ($0 * 4)),
        value: nil,
        type: .empty
      )
    }
    
    // 2. 레벨별 배치 (Level Design)
    switch level.id {
    case 1: // 주소의 중요성: 0x700C 찾기
      // 0x700C = 0x7000 + 12 (index 3)
      let targetIndex = 3
      slots[targetIndex].type = .value
      slots[targetIndex].value = 100 // 값은 중요하지 않음
      
      // 포인터 변수 준비
      slots[8].type = .pointer
      codeLog = "// Level 1: Drag the pointer to point to address 0x700C."
      
    case 2: // 이중 포인터: 직접 접근 금지, Double Pointer 이용
      // Target Value (Locked)
      let targetIndex = 7 // 0x701C
      slots[targetIndex].type = .value
      slots[targetIndex].value = 777
      slots[targetIndex].isLocked = true // 직접 연결 불가
      
      // Double Pointer (Existing Pointer)
      let linkIndex = 5 // 0x7014
      slots[linkIndex].type = .pointer
      slots[linkIndex].pointingTo = slots[targetIndex].address // Double Pointer -> Target
      
      // My Pointer
      let myPointerIndex = 14 // 0x7038
      slots[myPointerIndex].type = .pointer
      
      codeLog = "// Level 2: Data(0x701C) is locked. Do not access directly, use 'Double Pointer'."
      
    case 3: // 체인 연결: Start -> A -> B -> Treasure
      // Start (Pointer) -> A (Pointer) -> B (Pointer) -> Treasure (Value)
      
      // Treasure
      let treasureIndex = 15 // 0x703C
      slots[treasureIndex].type = .value
      slots[treasureIndex].value = 999
      
      // Node B (Pointer)
      let nodeBIndex = 11 // 0x702C
      slots[nodeBIndex].type = .pointer
      // slots[nodeBIndex].pointingTo = slots[treasureIndex].address // 사용자가 연결해야 함.
      
      // Node A (Pointer)
      let nodeAIndex = 5 // 0x7014
      slots[nodeAIndex].type = .pointer
      // slots[nodeAIndex].pointingTo = slots[nodeBIndex].address // 사용자가 연결해야 함
      
      // Start (Pointer)
      let startIndex = 0 // 0x7000
      slots[startIndex].type = .pointer
      
      codeLog = "// Level 3: Create a chain from Start(0x7000) to Treasure(0x703C)."
      
    default:
      codeLog = "// Sandbox Mode"
    }
    
    isSuccess = false
  }
  
  /// 현재 상태가 레벨 클리어 조건을 만족하는지 검사
  private func checkSuccess() {
    switch currentLesson.id {
    case 1:
      // Level 1: 0x700C 주소를 가리키는 포인터가 있는가?
      let hasCorrectPointer = slots.contains { slot in
        slot.type == .pointer && slot.pointingTo == "0x700C"
      }
      if hasCorrectPointer { finishLevel() }
      
    case 2:
      // Level 2: 내 포인터가 'Double Pointer'를 가리키고 있는가?
      // Target은 7번, Double Pointer는 5번, MyPointer는 14번(사용자가 바꿀 수 있나? 보통 드래그로)
      // 조건: 어떤 포인터든 '5번 슬롯(Double Pointer)'을 가리키면 성공 (단, 5번이 Target을 가리키고 있어야 함 - 초기값)
      let linkAddr = slots[5].address
      let hasConnectionToLink = slots.contains { slot in
        slot.type == .pointer && slot.pointingTo == linkAddr
      }
      
      if hasConnectionToLink { finishLevel() }
      
    case 3:
      // Level 3: Chain 연결 확인
      // Start(0) -> A(5) -> B(11) -> Treasure(15)
      let startSlot = slots[0]
      let nodeA = slots[5]
      let nodeB = slots[11]
      let treasure = slots[15] // 0x703C
      
      let isConnected = (startSlot.pointingTo == nodeA.address) &&
      (nodeA.pointingTo == nodeB.address) &&
      (nodeB.pointingTo == treasure.address)
      
      if isConnected { finishLevel() }
      
    default:
      break
    }
  }
  
  private func finishLevel() {
    isSuccess = true
    codeLog = "// Congratulations! Level Clear! 🎉"
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
