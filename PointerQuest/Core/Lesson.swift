import Foundation

/// Pointer Quest의 레슨 데이터를 관리하는 정적 객체
struct LessonData {
  static let lessons: [Lesson] = [
    .init(
      id: 1,
      title: "The Importance of Address",
      description: "It's not the value, but the 'Address' that matters.\nDrag the pointer to point to address.",
      iconName: "map"
    ),
    .init(
      id: 2,
      title: "Stepping Stone Pointer",
      description: "Data is protected by a Lock system.\nConnect via the existing 'Link Pointer' instead of accessing directly.",
      iconName: "arrow.triangle.merge"
    ),
    .init(
      id: 3,
      title: "Chain Connection",
      description: "Create a path to reach the data.\nConnect in order: Start -> Node A -> Node B -> Treasure.",
      iconName: "link"
    )
  ]
}

/// Pointer Quest의 각 학습 레슨을 정의하는 데이터 모델
struct Lesson: Identifiable, Hashable {
  let id: Int
  /// 레슨 제목
  let title: String
  /// 레슨 상세설명
  let description: String
  /// 레슨 카드에 표시될 아이콘 또는 이미지 이름 (SF Symbol 등)
  let iconName: String
}

/// 레슨 시작 시 특정 인덱스의 메모리 슬롯을 어떤 상태로 초기화할지 정의
struct SlotSeed: Hashable {
  /// 4x4 그리드에서의 슬롯 인덱스 (0..<16)
  let index: Int
  var type: MemorySlot.SlotType
  var value: Int? = nil
  /// 포인터일 때 초기에 가리켜야 할 대상 슬롯의 인덱스
  var pointingToIndex: Int? = nil
  var isLocked: Bool = false
}

/// 레슨의 클리어 조건을 표현하는 판정 규칙
enum SuccessCondition: Hashable {
  /// 어떤 포인터든 `index` 슬롯을 가리키면 클리어
  case anyPointerPointsTo(index: Int)
  /// `indices`가 순서대로 서로를 가리키는 체인이 완성되면 클리어 (마지막 원소는 값 슬롯)
  case chain(indices: [Int])
}

/// 레슨의 초기 배치와 클리어 조건을 데이터로 표현
struct LessonBlueprint: Hashable {
  var seeds: [SlotSeed]
  var successCondition: SuccessCondition
  var initialCodeLog: String
}
