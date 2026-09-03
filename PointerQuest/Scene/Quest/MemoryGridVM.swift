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

  /// 다음에 새로 부여할 범용 포인터 변수명(p1, p2, p3, ...)의 번호.
  /// 같은 레슨 안에서 여러 포인터가 만들어질 때(ex: 체인 연결) 전부 "p"로 겹쳐 보이지 않도록 한다.
  private var nextPointerNameIndex = 1

  /// 관찰형 레슨(`.inspectedAll`)에서 사용자가 탭해 내용을 확인한 슬롯의 인덱스.
  /// 레슨을 초기화하면 함께 비워진다
  private var inspectedIndices = Set<Int>()

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
    let selfIndex = slots.firstIndex(where: { $0.address == slot.address })

    // 1. 포인터인 경우 (어딘가를 가리키고 있음)
    if let targetAddress = slot.pointingTo,
       let targetIndex = slots.firstIndex(where: { $0.address == targetAddress })
    {

      let targetSlot = slots[targetIndex]

      // Case A: 가리킨 곳에 값이 있는 경우 (일반 포인터)
      if let targetValue = targetSlot.value {
        let targetName = resolveVariableName(for: targetIndex, fallback: "target")
        let selfName = selfIndex.map { resolveVariableName(for: $0, fallback: makePointerName()) } ?? "p"
        codeLog = """
        int \(targetName) = \(targetValue); // \(targetAddress)의 값
        int *\(selfName) = &\(targetName); // 이 슬롯(\(slot.address))이 \(targetName)을 가리킴
        // \(selfName) 자신도 메모리(\(slot.address))에 저장된 값(주소)입니다.
        """
      }
      // Case B: 가리킨 곳도 포인터인 경우 (이중 포인터)
      else if targetSlot.type == .pointer {
        // ptr1이 가리키는 최종 대상 찾기
        if let ultimateAddr = targetSlot.pointingTo,
           let ultimateIndex = slots.firstIndex(where: { $0.address == ultimateAddr }),
           let ultimateValue = slots[ultimateIndex].value {
          let ultimateName = resolveVariableName(for: ultimateIndex, fallback: "value")
          let targetName = resolveVariableName(for: targetIndex, fallback: "ptr1")
          let selfName = selfIndex.map { resolveVariableName(for: $0, fallback: "ptr2") } ?? "ptr2"
          codeLog = """
          int \(ultimateName) = \(ultimateValue); // \(ultimateAddr)의 값
          int *\(targetName) = &\(ultimateName); // \(targetName)이 \(ultimateName)를 가리킴
          int **\(selfName) = &\(targetName); // 이중 포인터 (이 슬롯이 \(targetName)을 가리킴)
          """
        } else {
          // 최종 대상이 없거나 값이 없는 경우 (단순 주소 표기)
          let targetName = resolveVariableName(for: targetIndex, fallback: "ptr1")
          let selfName = selfIndex.map { resolveVariableName(for: $0, fallback: "ptr2") } ?? "ptr2"
          codeLog = """
          int *\(targetName) = \(targetSlot.pointingTo ?? "NULL"); // \(targetAddress)
          int **\(selfName) = &\(targetName); // 이중 포인터 (이 슬롯이 \(targetName)을 가리킴)
          """
        }
      }
      // Case C: 가리킨 곳이 비어있는 경우
      else {
        let targetName = resolveVariableName(for: targetIndex, fallback: "unknown")
        let selfName = selfIndex.map { resolveVariableName(for: $0, fallback: makePointerName()) } ?? "p"
        codeLog = """
        int \(targetName); // \(targetAddress)의 변수가 초기화되지 않음
        int *\(selfName) = &\(targetName);
        // 경고: '\(selfName)'를 역참조하면 쓰레기 값이 반환됩니다.
        """
      }

      // 시각적 효과: 가리키는 대상 깜빡임
      highlightSlot(for: targetIndex)
      return
    }

    // 2. 값을 가진 변수인 경우
    if let value = slot.value {
      // 관찰형 레슨(레슨 0)에서는 이 탭 자체가 "상자를 열어 확인하는" 행동이므로 코드 로그도 그쪽에서 채운다
      if let selfIndex, recordInspection(of: selfIndex) { return }

      let name = selfIndex.map { resolveVariableName(for: $0, fallback: "val") } ?? "val"
      codeLog = "int \(name) = \(value); // \(slot.address)의 값"
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
        let targetName = resolveVariableName(for: targetIndex, fallback: "target")
        let pName = resolveVariableName(for: sourceIndex, fallback: makePointerName())
        codeLog = "int \(targetName) = \(randomValue);\nint *\(pName) = &\(targetName);\n// \(pName) 자신도 메모리(\(sourceAddress))에 저장된 값(주소)입니다."

        // 시각적 혼란을 줄이기 위해 타겟에도 하이라이트 효과
        highlightSlot(for: targetIndex)
      } else if slots[targetIndex].isReferenced,
                let existingPointerAddress = slots.first(where: {
                  $0.pointingTo == destinationAddress && $0.address != sourceAddress
                })?.address {
        // 직접 연결 자체는 허용하되(실제 C에서도 가능한 연산), 이중 포인터 연습을 유도하는 안내로 대체
        codeLog = "// 직접 연결도 가능하지만, 지금은 이중 포인터를 연습해봐요 — 이미 있는 포인터(\(existingPointerAddress))를 가리켜보세요."
      } else {
        // 목적지가 이미 이름을 가진 슬롯일 수 있으므로(레슨이 선언했거나 이전 상호작용에서 부여됨)
        // 주소 리터럴 대신 &변수명으로 표현해 "가리킨다 = 주소를 담는다" 개념을 코드로도 드러낸다
        let pName = resolveVariableName(for: sourceIndex, fallback: makePointerName())
        let destName = resolveVariableName(
          for: targetIndex,
          fallback: slots[targetIndex].value != nil ? "target" : makePointerName()
        )
        codeLog = "int *\(pName) = &\(destName);"
      }
    } else {
      let pName = resolveVariableName(for: sourceIndex, fallback: makePointerName())
      codeLog = "int *\(pName) = \(destinationAddress);"
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

    let pName = resolveVariableName(for: pointerIndex, fallback: makePointerName())

    // 로그 업데이트
    let targetSlot = slots[targetIndex]
    if let value = targetSlot.value {
      codeLog = "printf(\"%d\", *\(pName)); // 값: \(value)"
    } else if targetSlot.type == .pointer {
      // 이중 포인터인 경우 더 명확한 로그 제공
      codeLog = "printf(\"%p\", *\(pName)); // 이중 포인터 (대상도 포인터임)"
    } else {
      codeLog = "printf(\"%p\", *\(pName)); // 주소: \(targetAddr)"
    }
    
    // 3. 대상 슬롯 하이라이트 (포인터를 따라간 효과)
    print("역참조 성공! \(pointerAddr) -> \(targetAddr) (Value: \(slots[targetIndex].value ?? 0))")
    highlightSlot(for: targetIndex)
  }

  /// "힌트 보기" 버튼 탭 시, 레슨에 정의된 목표 코드를 코드 패널에 일시적으로 보여준다
  func showHint() {
    guard let hintCode = currentLesson.blueprint.hintCode else { return }
    codeLog = hintCode
  }
  
  /// 슬롯에 표시할 변수명을 정하고 `codeLog`에서도 함께 쓸 수 있도록 반환한다.
  /// 1) 슬롯에 이미 이름이 있으면 그대로 재사용한다 (누적 유지 — 상호작용을 거듭해도 라벨이 바뀌지 않음)
  /// 2) 레슨 블루프린트가 이 슬롯에 이름을 선언해뒀다면(`SlotSeed.variableName`) 그 이름을 우선 사용한다
  /// 3) 위 두 경우가 아니면 `fallback`(주로 범용 이름)을 사용한다
  private func resolveVariableName(for index: Int, fallback: @autoclosure () -> String) -> String {
    if let existing = slots[index].variableName { return existing }
    let name = currentLesson.blueprint.seeds.first(where: { $0.index == index })?.variableName ?? fallback()
    slots[index].variableName = name
    return name
  }

  /// 관찰형 레슨(`.inspectedAll`)에서 탭한 슬롯을 "확인함"으로 기록하고 코드 로그를 채운다.
  /// 성공 조건이 다르거나 확인 대상 슬롯이 아니면 아무 일도 하지 않고 `false`를 반환해 기본 로그가 그대로 쓰이게 한다
  /// - Returns: 이 탭을 관찰 행동으로 처리했는지 여부
  private func recordInspection(of index: Int) -> Bool {
    guard case .inspectedAll(let targets) = currentLesson.blueprint.successCondition,
          targets.contains(index),
          let value = slots[index].value
    else { return false }

    let isFirstInspection = inspectedIndices.insert(index).inserted
    let name = resolveVariableName(for: index, fallback: "val")
    let address = slots[index].address
    let remaining = targets.count - inspectedIndices.count

    if remaining > 0 {
      codeLog = """
      int \(name) = \(value); // 이름 \(name), 주소 \(address), 값 \(value)
      // 아직 열어보지 않은 상자가 \(remaining)개 남았어요.
      """
    } else {
      codeLog = "int \(name) = \(value); // 이름 \(name), 주소 \(address), 값 \(value)"
    }

    // 이미 확인한 슬롯을 다시 탭했을 때 완료 알럿이 다시 뜨지 않도록 처음 확인한 경우에만 판정한다
    if isFirstInspection { checkSuccess() }
    return true
  }

  /// 레슨이 이름을 선언하지 않은 슬롯에 붙일 범용 포인터 이름(p1, p2, ...)을 생성한다.
  private func makePointerName() -> String {
    defer { nextPointerNameIndex += 1 }
    return "p\(nextPointerNameIndex)"
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
    nextPointerNameIndex = 1
    inspectedIndices.removeAll()
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

    case .inspectedAll(let indices):
      // 지정된 슬롯을 모두 탭해 확인했으면 성공
      if indices.allSatisfy(inspectedIndices.contains) { finishLevel() }

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
