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
    if let selfIndex,
       let targetAddress = slot.pointingTo,
       let targetIndex = slots.firstIndex(where: { $0.address == targetAddress })
    {
      codeLog = pointerCode(at: selfIndex, targetIndex: targetIndex)

      // 시각적 효과: 가리키는 대상 깜빡임
      highlightSlot(for: targetIndex)
      return
    }

    // 2. 값을 가진 변수인 경우
    if let selfIndex, slot.value != nil {
      // 관찰형 레슨(레슨 0)에서는 이 탭 자체가 "상자를 열어 확인하는" 행동이므로 코드 로그도 그쪽에서 채운다
      if recordInspection(of: selfIndex) { return }

      codeLog = valueCode(at: selfIndex)
    }
    // 3. 빈 슬롯인 경우
    else {
      codeLog = "// 주소: \(slot.address)"
    }
  }
  
  /// 드래그 앤 드롭 작업이 완료되었을 때 호출.
  /// 자기 자신에게 드롭한 경우는 호출부(`MemoryItem`)가 걸러내므로 두 주소는 항상 다르다
  /// - Parameters:
  ///   - sourceAddress: 드래그를 시작한 슬롯(포인터가 될 슬롯)의 주소
  ///   - destinationAddress: 드롭된 위치의 슬롯(가리킴을 당할 대상)의 주소
  func handleDrop(sourceAddress: String, destinationAddress: String) {
    // 1. 드래그한 슬롯(Source)과 드롭된 슬롯(Target)의 인덱스를 찾기
    // 호출부(`MemoryItem`)는 드롭된 슬롯 자신의 주소를 넘기므로 대상은 항상 찾아진다.
    // 슬롯을 바꾸기 전에 둘 다 확인해, 대상을 못 찾았을 때 원본만 포인터로 바뀌는 일이 없게 한다
    guard let sourceIndex = slots.firstIndex(where: { $0.address == sourceAddress }),
          let targetIndex = slots.firstIndex(where: { $0.address == destinationAddress })
    else { return }

    // 2. 드래그한 슬롯을 pointer 타입으로 변경하고, 대상의 주소를 저장
    // C 언어의 `source = &destination;`과 같은 논리
    slots[sourceIndex].type = .pointer
    slots[sourceIndex].value = nil // 기존 값이 남아있으면 UI에서 포인터 주소가 가려짐
    slots[sourceIndex].pointingTo = destinationAddress

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
    
    // 2. 빈 칸은 역참조할 대상 자체가 없다.
    // 학습자가 무언가를 잘못한 것이 아니므로 에러(빨간 배경 + 흔들림)로 다루지 않고 아무 일도 하지 않는다.
    // `codeLog`도 여기서 건드리지 않는다 — 같은 탭에 `handleTap`이 함께 반응해 주소 한 줄(`// 주소: ...`)을
    // 이미 남기므로, 여기서 또 쓰면 두 문구가 순서에 따라 엇갈린다
    guard pointerSlot.type != .empty else { return }

    // 3. 해당 슬롯이 포인터 타입인지 확인
    guard pointerSlot.type == .pointer,
          let targetAddr = pointerSlot.pointingTo,
          let targetIndex = slots.firstIndex(where: { $0.address == targetAddr })
    else {
      // 값 칸(`*a`는 실제 C 컴파일 에러)이거나, 아직 아무 곳도 가리키지 않는 포인터인 경우.
      // 둘 다 실제 C에서 오류이므로 에러 피드백을 유지한다
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
    
    // 4. 대상 슬롯 하이라이트 (포인터를 따라간 효과)
    print("역참조 성공! \(pointerAddr) -> \(targetAddr) (Value: \(slots[targetIndex].value ?? 0))")
    highlightSlot(for: targetIndex)
  }

  /// "힌트 보기" 버튼 탭 시, 레슨에 정의된 목표 코드를 코드 패널에 일시적으로 보여준다
  func showHint() {
    guard let hintCode = currentLesson.blueprint.hintCode else { return }
    codeLog = hintCode
  }

  /// 포인터 칸을 탭했을 때 코드 패널에 보여줄 코드를 만든다. 강조 같은 시각 효과는 담지 않는다.
  ///
  /// 탭(`handleTap`)과 레슨 완료가 같은 함수를 쓴다. 두 곳에서 따로 문구를 만들면
  /// 같은 연결이 상황에 따라 다른 C로 찍힌다 — Task 27에서 고친 것과 같은 부류의 문제다
  /// - Parameters:
  ///   - index: 탭한 포인터 칸의 인덱스
  ///   - targetIndex: 그 포인터가 가리키는 칸의 인덱스
  private func pointerCode(at index: Int, targetIndex: Int) -> LocalizedStringResource {
    let selfAddress = slots[index].address
    let targetSlot = slots[targetIndex]
    let targetAddress = targetSlot.address

    // Case A: 가리킨 곳에 값이 있는 경우 (일반 포인터)
    if let targetValue = targetSlot.value {
      let targetName = resolveVariableName(for: targetIndex, fallback: "target")
      let selfName = resolveVariableName(for: index, fallback: makePointerName())
      return """
      int \(targetName) = \(targetValue); // \(targetAddress)의 값
      int *\(selfName) = &\(targetName); // 이 슬롯(\(selfAddress))이 \(targetName)을 가리킴
      // \(selfName) 자신도 메모리(\(selfAddress))에 저장된 값(주소)입니다.
      """
    }

    // Case B: 가리킨 곳도 포인터인 경우 (이중 포인터)
    if targetSlot.type == .pointer {
      // ptr1이 가리키는 최종 대상 찾기
      if let ultimateAddr = targetSlot.pointingTo,
         let ultimateIndex = slots.firstIndex(where: { $0.address == ultimateAddr }),
         let ultimateValue = slots[ultimateIndex].value {
        let ultimateName = resolveVariableName(for: ultimateIndex, fallback: "value")
        let targetName = resolveVariableName(for: targetIndex, fallback: "ptr1")
        let selfName = resolveVariableName(for: index, fallback: "ptr2")
        return """
        int \(ultimateName) = \(ultimateValue); // \(ultimateAddr)의 값
        int *\(targetName) = &\(ultimateName); // \(targetName)이 \(ultimateName)를 가리킴
        int **\(selfName) = &\(targetName); // 이중 포인터 (이 슬롯이 \(targetName)을 가리킴)
        """
      }

      // 최종 대상에 아직 값이 없는 경우. 체인이 세 칸 이상이거나(레슨 3의 start) 대상이
      // 아무 곳도 가리키지 않을 때 여기로 온다.
      //
      // **별 개수를 `int *`로 고정하면 안 된다.** 포인터를 가리키는 포인터가 값을 가리키는
      // 것처럼 보인다. 주소 리터럴을 그대로 넣는 것도 안 된다 — `int *p = 0x702C;`는
      // 형변환 없이 컴파일되지 않는다. 둘 다 실제 체인 깊이와 이름으로 대신한다
      let targetName = resolveVariableName(for: targetIndex, fallback: "ptr1")
      let selfName = resolveVariableName(for: index, fallback: "ptr2")
      let targetStars = pointerStars(for: targetIndex)
      let selfStars = pointerStars(for: index)

      // 세 칸 이상을 건너뛰는 자리에서는 타입을 적지 않고 연결만 적는다.
      //
      // `int ***`는 문법상 옳지만 이 앱이 어디서도 설명하지 않은 표기다. 실제 C에서
      // 이 표기를 볼 일이 없는 것은 **연결 리스트가 칸을 구조체로 묶어 `*`가 늘어나지
      // 않게 만들기 때문**이고, 구조체는 챕터 4의 주제라 지금 꺼낼 수 없다.
      //
      // 그렇다고 별 개수를 낮추면 타입이 틀려져 Task 27에서 고친 문제로 돌아간다.
      // 대신 **선언을 빼고 연결만 남긴 뒤, 별이 몇 개 붙는지를 주석으로 설명한다** —
      // 레슨 2가 가르친 "`*`가 하나 늘어날 때마다 한 번 더 따라간다"와 이어진다
      if selfStars.count >= 3 {
        let path = chainNames(from: index).joined(separator: " -> ")
        return """
        // \(path)
        \(selfName) = &\(targetName); // \(selfName)는 \(targetName)의 주소만 담습니다
        // 끝까지 따라가려면 여기서 \(selfStars.count)번을 거칩니다. 거치는 횟수만큼 타입에 *가 붙습니다.
        // 실제 C는 칸을 구조체로 묶어 *가 늘어나지 않게 만듭니다. 그건 나중에 다룹니다.
        """
      }

      if let ultimateAddr = targetSlot.pointingTo,
         let ultimateIndex = slots.firstIndex(where: { $0.address == ultimateAddr }) {
        let ultimateName = resolveVariableName(
          for: ultimateIndex,
          fallback: slots[ultimateIndex].type == .pointer ? makePointerName() : "target"
        )
        return """
        int \(targetStars)\(targetName) = &\(ultimateName); // \(targetName)이 \(ultimateName)을 가리킴
        int \(selfStars)\(selfName) = &\(targetName); // 이 슬롯이 \(targetName)을 가리킴
        """
      }

      return """
      int \(targetStars)\(targetName) = NULL; // \(targetAddress)는 아직 아무 곳도 가리키지 않습니다
      int \(selfStars)\(selfName) = &\(targetName); // 이 슬롯이 \(targetName)을 가리킴
      """
    }

    // Case C: 가리킨 곳이 비어있는 경우
    let targetName = resolveVariableName(for: targetIndex, fallback: "unknown")
    let selfName = resolveVariableName(for: index, fallback: makePointerName())
    return """
    int \(targetName); // \(targetAddress)의 변수가 초기화되지 않음
    int *\(selfName) = &\(targetName);
    // 경고: '\(selfName)'를 역참조하면 쓰레기 값이 반환됩니다.
    """
  }

  /// 값 칸을 C 선언 한 줄로 표현한다 (ex: `int age = 20; // 0x7004의 값`)
  /// 탭과 레슨 0 완료가 같은 문구를 쓰도록 한 곳에서 만든다
  private func valueCode(at index: Int) -> LocalizedStringResource {
    let name = resolveVariableName(for: index, fallback: "val")
    return "int \(name) = \(slots[index].value ?? 0); // \(slots[index].address)의 값"
  }
  
  /// 슬롯에 표시할 변수명을 정하고 `codeLog`에서도 함께 쓸 수 있도록 반환한다.
  /// 1) 슬롯에 이미 이름이 있으면 그대로 재사용한다 (누적 유지 — 상호작용을 거듭해도 라벨이 바뀌지 않음)
  /// 2) 레슨 블루프린트가 이 슬롯에 이름을 선언해뒀다면(`SlotSeed.variableName`) 그 이름을 우선 사용한다
  /// 3) 위 두 경우가 아니면 `fallback`(주로 범용 이름)을 사용한다
  ///
  /// 어느 경우든 `uniqueName`을 거쳐 **다른 슬롯과 이름이 겹치지 않는 것을 보장한다.**
  /// `fallback`은 `"target"`처럼 번호가 없는 문자열이라 여러 슬롯이 같은 이름을 받을 수 있고,
  /// 그러면 코드 패널에 컴파일되지 않는 C가 찍힌다
  private func resolveVariableName(for index: Int, fallback: @autoclosure () -> String) -> String {
    if let existing = slots[index].variableName { return existing }
    let declared = currentLesson.blueprint.seeds.first(where: { $0.index == index })?.variableName
    let name = uniqueName(declared ?? fallback())
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
  /// 이미 쓰이고 있는 번호는 건너뛴다 — 레슨이 `p2` 같은 이름을 직접 선언했을 때 겹치지 않게 한다
  private func makePointerName() -> String {
    while true {
      let name = "p\(nextPointerNameIndex)"
      nextPointerNameIndex += 1
      if !isNameTaken(name) { return name }
    }
  }

  /// 다른 슬롯이 이미 쓰고 있는 이름이면 뒤에 번호를 붙여 겹치지 않게 한다 (target, target2, ...).
  ///
  /// 겹친 이름을 그대로 두면 코드 패널에 실제 C에서 컴파일되지 않는 문장이 찍힌다.
  /// 예를 들어 빈 칸에 연결할 때마다 목적지가 전부 `target`이 되면, 그중 하나가 다시 포인터가 되는 순간
  /// `int *target = &target;`이 나온다 — 자기 자신의 주소를 담는 선언이라 C가 거부한다
  private func uniqueName(_ base: String) -> String {
    guard isNameTaken(base) else { return base }
    var suffix = 2
    while isNameTaken("\(base)\(suffix)") { suffix += 1 }
    return "\(base)\(suffix)"
  }

  private func isNameTaken(_ name: String) -> Bool {
    slots.contains { $0.variableName == name }
  }

  /// 이 슬롯을 C로 선언할 때 `int`와 이름 사이에 들어갈 `*` 문자열을 만든다.
  ///
  /// 값 칸은 별이 없고(`int treasure`), 값을 가리키는 포인터는 하나(`int *nodeB`),
  /// 그 포인터를 가리키는 포인터는 둘(`int **nodeA`)이다. 체인을 실제로 따라가 세므로
  /// 레슨 3처럼 세 칸을 건너뛰는 연결에서도 타입이 맞는다
  private func pointerStars(for index: Int) -> String {
    String(repeating: "*", count: pointerDepth(of: index))
  }

  /// 이 슬롯에서 시작해 체인을 따라가며 지나는 칸의 이름을 순서대로 모은다.
  ///
  /// 세 칸 이상을 건너뛸 때 `start -> nodeA -> nodeB -> treasure`처럼 경로 전체를 보여주기
  /// 위한 것이다. 타입을 적지 않는 대신 이 줄이 "어디를 거쳐 어디에 닿는지"를 대신 말한다.
  /// 이름 부여 규칙은 코드 패널의 다른 분기와 같고, `pointerDepth(of:)`와 같은 방식으로 순환을 막는다
  private func chainNames(from index: Int) -> [String] {
    var names: [String] = []
    var visited = Set<Int>()
    var current = index

    while visited.insert(current).inserted {
      let slot = slots[current]
      let isPointer = slot.type == .pointer
      names.append(
        resolveVariableName(
          for: current,
          fallback: isPointer ? makePointerName() : (slot.value != nil ? "target" : "unknown")
        )
      )

      guard isPointer,
            let next = slot.pointingTo,
            let nextIndex = slots.firstIndex(where: { $0.address == next })
      else { break }
      current = nextIndex
    }

    return names
  }

  /// 체인을 따라가며 포인터를 몇 번 거치는지 센다.
  /// 플레이그라운드는 `A -> B -> A` 같은 순환도 만들 수 있으므로 지나온 칸을 기억해 멈춘다
  private func pointerDepth(of index: Int) -> Int {
    var depth = 0
    var visited = Set<Int>()
    var current = index

    while slots[current].type == .pointer {
      guard visited.insert(current).inserted else { break }
      depth += 1
      guard let next = slots[current].pointingTo,
            let nextIndex = slots.firstIndex(where: { $0.address == next })
      else { break }
      current = nextIndex
    }

    return depth
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
