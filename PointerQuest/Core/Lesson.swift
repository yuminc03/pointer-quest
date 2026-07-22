import Foundation

/// Pointer Quest의 레슨 데이터를 관리하는 정적 객체
struct LessonData {
  static let lessons: [Lesson] = chapters.flatMap(\.lessons)

  /// 클리어 조건 없이 자유롭게 포인터를 연결/해제할 수 있는 샌드박스(Playground) 레슨
  /// `chapters`/`lessons`에는 포함하지 않고, Main 화면의 별도 진입점에서만 참조한다
  static let sandboxLesson = Lesson(
    id: 0,
    title: "Playground",
    description: "Freely connect and disconnect pointers here.\nThere's no mission or wrong answer — just explore.",
    iconName: "wand.and.stars",
    blueprint: .init(
      seeds: [],
      successCondition: .sandbox,
      initialCodeLog: "// Playground: Freely connect pointers. Nothing to break here."
    )
  )

  static let chapters: [Chapter] = [
    .init(
      id: 1,
      title: "주소와 포인터",
      lessons: [
        .init(
          id: 1,
          title: "The Importance of Address",
          description: "It's not the value, but the 'Address' that matters.\nDrag the pointer to point to address.",
          iconName: "map",
          blueprint: .init(
            seeds: [
              .init(index: 3, type: .value, value: 100),
              .init(index: 8, type: .pointer)
            ],
            successCondition: .anyPointerPointsTo(index: 3),
            initialCodeLog: "// Lesson 1: Drag the pointer to point to address 0x700C."
          )
        ),
        .init(
          id: 2,
          title: "Stepping Stone Pointer",
          description: "Data is protected by a Lock system.\nConnect via the existing 'Link Pointer' instead of accessing directly.",
          iconName: "arrow.triangle.merge",
          blueprint: .init(
            seeds: [
              .init(index: 7, type: .value, value: 777, isLocked: true),
              .init(index: 5, type: .pointer, pointingToIndex: 7),
              .init(index: 14, type: .pointer)
            ],
            successCondition: .anyPointerPointsTo(index: 5),
            initialCodeLog: "// Lesson 2: Data(0x701C) is locked. Do not access directly, use 'Double Pointer'."
          )
        ),
        .init(
          id: 3,
          title: "Chain Connection",
          description: "Create a path to reach the data.\nConnect in order: Start -> Node A -> Node B -> Treasure.",
          iconName: "link",
          blueprint: .init(
            seeds: [
              .init(index: 15, type: .value, value: 999),
              .init(index: 11, type: .pointer),
              .init(index: 5, type: .pointer),
              .init(index: 0, type: .pointer)
            ],
            successCondition: .chain(indices: [0, 5, 11, 15]),
            initialCodeLog: "// Lesson 3: Create a chain from Start(0x7000) to Treasure(0x703C)."
          )
        )
      ]
    )
  ]
}

/// 여러 레슨을 하나의 학습 주제로 묶는 그룹
struct Chapter: Identifiable, Hashable {
  let id: Int
  let title: LocalizedStringResource
  var lessons: [Lesson]

  // `LocalizedStringResource`는 synthesized Hashable 대상이 아니므로 `id` 기준으로 직접 구현한다.
  static func == (lhs: Chapter, rhs: Chapter) -> Bool { lhs.id == rhs.id }
  func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

/// Pointer Quest의 각 학습 레슨을 정의하는 데이터 모델
struct Lesson: Identifiable, Hashable {
  let id: Int
  /// 레슨 제목
  let title: LocalizedStringResource
  /// 레슨 상세설명
  let description: LocalizedStringResource
  /// 레슨 카드에 표시될 아이콘 또는 이미지 이름 (SF Symbol 등)
  let iconName: String
  /// 레슨의 초기 배치와 클리어 조건
  let blueprint: LessonBlueprint

  // `LocalizedStringResource`는 synthesized Hashable 대상이 아니므로 `id` 기준으로 직접 구현한다.
  static func == (lhs: Lesson, rhs: Lesson) -> Bool { lhs.id == rhs.id }
  func hash(into hasher: inout Hasher) { hasher.combine(id) }
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
  /// 클리어 조건 없이 자유롭게 탐험하는 샌드박스 모드
  case sandbox
}

/// 레슨의 초기 배치와 클리어 조건을 데이터로 표현
struct LessonBlueprint: Hashable {
  var seeds: [SlotSeed]
  var successCondition: SuccessCondition
  var initialCodeLog: String
}
