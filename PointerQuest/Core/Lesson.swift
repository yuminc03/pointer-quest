import Foundation

/// Pointer Quest의 레슨 데이터를 관리하는 정적 객체
struct LessonData {
  static let lessons: [Lesson] = chapters.flatMap(\.lessons)

  /// 클리어 조건 없이 자유롭게 포인터를 연결/해제할 수 있는 샌드박스(Playground) 레슨
  /// `chapters`/`lessons`에는 포함하지 않고, Main 화면의 별도 진입점에서만 참조한다
  static let sandboxLesson = Lesson(
    id: 0,
    title: "플레이그라운드",
    description: "여기서는 자유롭게 포인터를 연결하고 해제할 수 있어요.\n미션도 정답도 없으니 마음껏 탐험해 보세요.",
    iconName: "wand.and.stars",
    blueprint: .init(
      seeds: [],
      successCondition: .sandbox,
      initialCodeLog: "// 플레이그라운드: 자유롭게 포인터를 연결해보세요. 여기선 아무것도 망가지지 않아요."
    )
  )

  static let chapters: [Chapter] = [
    .init(
      id: 1,
      title: "주소와 포인터",
      lessons: [
        .init(
          id: 1,
          title: "주소가 중요한 이유",
          description: "값이 아니라 '주소'가 중요합니다.\n포인터를 드래그해서 주소를 가리켜보세요.",
          iconName: "map",
          blueprint: .init(
            seeds: [
              .init(index: 3, type: .value, value: 100),
              .init(index: 8, type: .pointer)
            ],
            successCondition: .anyPointerPointsTo(index: 3),
            initialCodeLog: "// 레슨 1: 포인터를 드래그해서 0x700C 주소를 가리키세요."
          )
        ),
        .init(
          id: 2,
          title: "징검다리 포인터",
          description: "이미 데이터를 가리키는 포인터가 있습니다.\n새 포인터로 그 포인터를 가리켜 이중 포인터를 만들어보세요.",
          iconName: "arrow.triangle.merge",
          blueprint: .init(
            seeds: [
              .init(index: 7, type: .value, value: 777, isReferenced: true),
              .init(index: 5, type: .pointer, pointingToIndex: 7),
              .init(index: 14, type: .pointer)
            ],
            successCondition: .anyPointerPointsTo(index: 5),
            initialCodeLog: "// 레슨 2: 0x701C를 직접 가리켜도 되지만, 이미 있는 포인터(0x7014)를 가리켜 이중 포인터를 만들어보세요.",
            hintCode: "int **pp = &p; // p(0x7014)를 가리키는 이중 포인터"
          )
        ),
        .init(
          id: 3,
          title: "체인 연결",
          description: "데이터에 도달하는 경로를 만드세요.\n순서대로 연결하세요: 시작 -> 노드 A -> 노드 B -> 보물.",
          iconName: "link",
          blueprint: .init(
            seeds: [
              .init(index: 15, type: .value, value: 999, variableName: "treasure"),
              .init(index: 11, type: .pointer, variableName: "nodeB"),
              .init(index: 5, type: .pointer, variableName: "nodeA"),
              .init(index: 0, type: .pointer, variableName: "start")
            ],
            successCondition: .chain(indices: [0, 5, 11, 15]),
            initialCodeLog: "// 레슨 3: Start(0x7000)에서 Treasure(0x703C)까지 체인을 만드세요."
          )
        )
      ]
    ),
    .init(
      id: 2,
      title: "이중 포인터 심화",
      lessons: [comingSoonLesson(id: 4, title: "이중 포인터 심화")]
    ),
    .init(
      id: 3,
      title: "배열과 포인터 연산",
      lessons: [comingSoonLesson(id: 5, title: "배열과 포인터 연산")]
    ),
    .init(
      id: 4,
      title: "구조체와 포인터",
      lessons: [comingSoonLesson(id: 6, title: "구조체와 포인터")]
    ),
    .init(
      id: 5,
      title: "malloc·free와 스택 vs 힙",
      lessons: [comingSoonLesson(id: 7, title: "malloc·free와 스택 vs 힙")]
    )
  ]

  /// 아직 콘텐츠가 저작되지 않은 챕터를 나타내는 "Coming Soon" placeholder 레슨
  /// `successCondition`은 실제로 열람되지 않으므로(Main 화면에서 진입 자체를 막음) 새 케이스 없이 `.sandbox`를 재사용한다
  private static func comingSoonLesson(id: Int, title: LocalizedStringResource) -> Lesson {
    .init(
      id: id,
      title: title,
      description: "다음 업데이트에서 만나볼 수 있어요.",
      iconName: "lock.fill",
      blueprint: .init(seeds: [], successCondition: .sandbox, initialCodeLog: ""),
      isComingSoon: true
    )
  }
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
  /// 아직 콘텐츠가 저작되지 않아 "Coming Soon"으로만 표시되는 레슨인지 여부
  var isComingSoon = false

  // `LocalizedStringResource`는 synthesized Hashable 대상이 아니므로 `id` 기준으로 직접 구현한다.
  static func == (lhs: Lesson, rhs: Lesson) -> Bool { lhs.id == rhs.id }
  func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

/// 레슨 시작 시 특정 인덱스의 메모리 슬롯을 어떤 상태로 초기화할지 정의
struct SlotSeed: Hashable {
  /// 4x4 그리드에서의 슬롯 인덱스 (0..<16)
  let index: Int
  var type: MemorySlot.SlotType
  var value: Int?
  /// 포인터일 때 초기에 가리켜야 할 대상 슬롯의 인덱스
  var pointingToIndex: Int?
  /// 다른 포인터가 이미 이 슬롯을 가리키고 있음을 나타내는 배지용 플래그 (접근 차단 없음)
  var isReferenced = false
  /// 이 슬롯이 코드 상에서 쓰이길 원하는 변수명 (ex: 체인 레슨의 "start"/"nodeA"/"nodeB"/"treasure")
  /// 지정하지 않으면 `MemoryGridVM`이 범용 이름(target/p1/p2/... 등)을 자동으로 부여한다
  var variableName: String?
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
struct LessonBlueprint {
  var seeds: [SlotSeed]
  var successCondition: SuccessCondition
  var initialCodeLog: LocalizedStringResource
  /// "힌트 보기" 버튼을 탭했을 때 코드 패널에 일시적으로 보여줄 목표 코드 (정답을 자동 완성하지 않고 힌트만 제공)
  var hintCode: LocalizedStringResource?
}
