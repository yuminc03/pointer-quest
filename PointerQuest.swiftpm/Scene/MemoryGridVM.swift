import Foundation

@MainActor
final class MemoryGridVM: ObservableObject {
  /// 메모리 Cells
  @Published private(set) var slots = [MemorySlot]()
  /// 현재 실행된 동작을 C 코드로 보여주는 로그
  @Published var codeLog = "// The executed operation is represented as C language code."
  /// 현재 진행 중인 레벨
  @Published private(set) var currentLevel: Level
  /// 미션 성공 여부
  @Published var isSuccess = false
  
  init(level: Level = LevelData.levels[0]) {
    self.currentLevel = level
    self.setupLevel(level: level)
  }
  
  /// 슬롯 탭 처리 (Level 1 판정 포함)
  func handleTap(_ slot: MemorySlot) {
    print("클릭된 메모리 주소: \(slot.address)")
    
    // Level 1: 탭한 슬롯이 정답인지 검사
    if currentLevel.id == 1 {
      if slot.value == 10 {
        finishLevel()
      } else {
        // 오답 피드백
        codeLog = "// 거기는 정답이 아닙니다. 값이 10인 곳을 찾아보세요!"
        if let index = slots.firstIndex(where: { $0.id == slot.id }) {
          triggerError(for: index)
        }
      }
    }
  }
  
  /// 드래그 앤 드롭 작업이 완료되었을 때 호출
  /// - Parameters:
  ///   - sourceAddress: 드래그를 시작한 슬롯(포인터가 될 슬롯)의 주소
  ///   - destinationAddress: 드롭된 위치의 슬롯(가리킴을 당할 대상)의 주소
  func handleDrop(sourceAddress: String, destinationAddress: String) {
    // 1. 드래그한 슬롯(Source)의 인덱스를 찾기
    // 자기 자신을 가리키는 것은 방지 (Self-reference Prevention)
    if sourceAddress == destinationAddress { return }
    
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
  private func setupLevel(level: Level) {
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
    case 1: // 주소 찾기: 값 10이 들어있는 곳 찾기
      let targetIndex = Int.random(in: 0..<16)
      slots[targetIndex].type = .value
      slots[targetIndex].value = 10
      codeLog = "// Level 1: 값이 10인 메모리 공간을 찾으세요!"
      
    case 2: // 포인터 연결: 변수 p(pointer)가 99(value)를 가리키게 하기
      slots[0].type = .value
      slots[0].value = 99
      
      slots[4].type = .pointer // p 변수 역할 (초기엔 비어있음)
      slots[4].pointingTo = nil
      codeLog = "// Level 2: 포인터 변수(Pointer)를 드래그하여 99를 가리키게 만드세요."
      
    case 3: // 이중 포인터: pp -> p -> value
      slots[0].type = .value
      slots[0].value = 777
      
      slots[1].type = .pointer
      slots[1].pointingTo = slots[0].address // p -> 777 (이미 연결됨)
      
      slots[5].type = .pointer // pp (비어있음)
      codeLog = "// Level 3: 포인터가 포인터를 가리키게 해보세요."
      
    default:
      codeLog = "// Sandbox Mode"
    }
    
    isSuccess = false
  }
  
  /// 현재 상태가 레벨 클리어 조건을 만족하는지 검사
  private func checkSuccess() {
    switch currentLevel.id {
    case 1:
      // Level 1: 숫자 찾기 (숨바꼭질)
      // Level 1 성공 판정은 탭 제스처에서 수행하는 것이 자연스러움 (View에서 처리하거나 별도 함수)
      // 여기서는 구조상 일단 비워둠.
      break
      
    case 2:
      // Level 2: 포인터 연결하기 (드래그)
      // 조건: 값이 99인 슬롯을 가리키는 포인터가 존재하는가?
      // slots[0]이 99라고 가정 (초기화 로직 기준)
      let targetAddr = slots[0].address
      let hasPointer = slots.contains { slot in
        slot.type == .pointer && slot.pointingTo == targetAddr
      }
      if hasPointer { finishLevel() }
      
    case 3:
      // Level 3: 이중 포인터 만들기
      // 조건: 다른 포인터를 가리키는 포인터(이중 포인터)가 존재하는가?
      let doublePointer = slots.first { slot in
        guard slot.type == .pointer, let targetAddr = slot.pointingTo else { return false }
        // 가리키는 대상(target)도 포인터여야 함
        if let targetSlot = slots.first(where: { $0.address == targetAddr }) {
          return targetSlot.type == .pointer
        }
        return false
      }
      if doublePointer != nil { finishLevel() }
      
    default:
      break
    }
  }
  
  private func finishLevel() {
    isSuccess = true
    codeLog = "// 축하합니다! Level Clear! 🎉"
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
