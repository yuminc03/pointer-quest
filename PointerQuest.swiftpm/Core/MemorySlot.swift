import Foundation

/// 컴퓨터의 메모리 Cell
struct MemorySlot: Identifiable, Hashable {
  let id = UUID()
  /// 주소값 (ex: "0x7FFEE")
let address: String
  /// 메모리 칸에 저장된 정수값
  /// type이 .value일 때만 의미를 가지며, .pointer일 때는 보통 비워두거나
  /// 가리키는 대상의 데이터를 보여주는 용도로 사용
  var value: Int?
  /// 메모리 슬롯의 역할
  var type: SlotType
  /// pointer일 때, 가리키는 대상의 주소 저장
  /// C 언어의 `int *p = &a;` 에서 `p`가 가진 `&a` 값을 의미
  var pointingTo: String?
  /// UI에서 사용자가 해당 칸을 선택하거나
  /// 포인터 추적(Trace) 중일 때 시각적으로 강조하기 위한 상태값
  var isHighlighted = false
  /// 오류 발생 시 시각적 피드백(흔들림, 빨간색)을 주기 위한 상태값
  var isError = false
  /// Level 2 등에서 잠김 상태를 표현 (역참조로만 풀 수 있음)
  var isLocked = false
  
  /// 메모리 슬롯의 역할
  enum SlotType {
    /// 일반 변수
    case value
    /// 주소값
    case pointer
    /// 빈 공간
    case empty
  }
}
