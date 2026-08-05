import Foundation

@MainActor
final class MemoryGridVM: ObservableObject {
  /// 메모리 Cells
  @Published private(set) var slots = [MemorySlot]()
  /// 현재 실행된 동작을 C 코드로 보여주는 로그
  @Published var codeLog: LocalizedStringResource = "// 실행된 연산을 C 언어 코드로 표현합니다."
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

    // 1. 포인터인 경우 (어딘가를 가리키고 있음)
    if let targetAddress = slot.pointingTo,
       let targetIndex = slots.firstIndex(where: { $0.address == targetAddress })
    {
      
      let targetSlot = slots[targetIndex]
      
      // Case A: 가리킨 곳에 값이 있는 경우 (일반 포인터)
      if let targetValue = targetSlot.value {
        codeLog = """
        int target = \(targetValue); // \(targetAddress)의 값
        int *p = &target; // 이 슬롯(\(slot.address))이 target을 가리킴
        """
      }
      // Case B: 가리킨 곳도 포인터인 경우 (이중 포인터)
      else if targetSlot.type == .pointer {
        // ptr1이 가리키는 최종 대상 찾기
        if let ultimateAddr = targetSlot.pointingTo,
           let ultimateIndex = slots.firstIndex(where: { $0.address == ultimateAddr }),
           let ultimateValue = slots[ultimateIndex].value {
          codeLog = """
          int value = \(ultimateValue); // \(ultimateAddr)의 값
          int *ptr1 = &value; // ptr1이 value를 가리킴
          int **ptr2 = &ptr1; // 이중 포인터 (이 슬롯이 ptr1을 가리킴)
          """
        } else {
          // 최종 대상이 없거나 값이 없는 경우 (단순 주소 표기)
          codeLog = """
          int *ptr1 = \(targetSlot.pointingTo ?? "NULL"); // \(targetAddress)
          int **ptr2 = &ptr1; // 이중 포인터 (이 슬롯이 ptr1을 가리킴)
          """
        }
      }
      // Case C: 가리킨 곳이 비어있는 경우
      else {
        codeLog = """
        int unknown; // \(targetAddress)의 변수가 초기화되지 않음
        int *p = &unknown;
        // 경고: 'p'를 역참조하면 쓰레기 값이 반환됩니다.
        """
      }
      
      // 시각적 효과: 가리키는 대상 깜빡임
      highlightSlot(for: targetIndex)
      return
    }
    
    // 2. 값을 가진 변수인 경우
    if let value = slot.value {
      codeLog = "int val = \(value); // \(slot.address)의 값"
    }
    // 3. 빈 슬롯인 경우
    else {
      codeLog = "// 주소: \(slot.address)"
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
      codeLog = "// 포인터는 자기 자신을 가리킬 수 없습니다. 다른 주소를 선택해 연결하세요."
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
      codeLog = "// 오류: 유효하지 않은 포인터입니다."
      triggerError(for: pointerIndex)
      return
    }
    
    // 로그 업데이트
    let targetSlot = slots[targetIndex]
    if let value = targetSlot.value {
      codeLog = "printf(\"%d\", *p); // 값: \(value)"
    } else if targetSlot.type == .pointer {
      // 이중 포인터인 경우 더 명확한 로그 제공
      codeLog = "printf(\"%p\", *p); // 이중 포인터 (대상도 포인터임)"
    } else {
      codeLog = "printf(\"%p\", *p); // 주소: \(targetAddr)"
    }
    
    // 3. 대상 슬롯 하이라이트 (포인터를 따라간 효과)
    print("역참조 성공! \(pointerAddr) -> \(targetAddr) (Value: \(slots[targetIndex].value ?? 0))")
    highlightSlot(for: targetIndex)
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
  
  /// 4 X 4 그리드 형태 가상 메모리 주소를 생성 및 블루프린트 기반 초기화
  private func setupLevel(level: Lesson) {
    // 1. 기본 빈 슬롯 16개 생성
    slots = (0 ..< 16).map {
      MemorySlot(
        address: String(format: "0x%04X", 0x7000 + ($0 * 4)),
        value: nil,
        type: .empty
      )
    }

    // 2. 블루프린트에 정의된 시드로 슬롯 배치
    for seed in level.blueprint.seeds {
      slots[seed.index].type = seed.type
      slots[seed.index].value = seed.value
      slots[seed.index].isReferenced = seed.isReferenced
      if let pointingToIndex = seed.pointingToIndex {
        slots[seed.index].pointingTo = slots[pointingToIndex].address
      }
    }

    codeLog = level.blueprint.initialCodeLog
    isSuccess = false
  }
  
  /// 현재 상태가 레슨의 클리어 조건(블루프린트의 `successCondition`)을 만족하는지 검사
  private func checkSuccess() {
    switch currentLesson.blueprint.successCondition {
    case .anyPointerPointsTo(let index):
      // 어떤 포인터든 대상 슬롯의 주소를 가리키면 성공
      let targetAddress = slots[index].address
      let hasCorrectPointer = slots.contains { slot in
        slot.type == .pointer && slot.pointingTo == targetAddress
      }
      if hasCorrectPointer { finishLevel() }

    case .chain(let indices):
      // indices가 순서대로 서로를 가리키는 체인이 완성되었는지 확인
      let isConnected = zip(indices, indices.dropFirst()).allSatisfy { current, next in
        slots[current].pointingTo == slots[next].address
      }
      if isConnected { finishLevel() }

    case .sandbox:
      // 샌드박스 모드는 클리어 조건이 없어 항상 자유롭게 탐험 가능
      break
    }
  }
  
  private func finishLevel() {
    isSuccess = true
    codeLog = "// 잘했어요! 레슨 완료! 🎉"
    LessonProgressStore.shared.markCompleted(currentLesson.id)
  }
}
