import Foundation

/// Pointer Quest의 레슨 데이터를 관리하는 정적 객체
struct LessonData {
  static let lessons: [Lesson] = chapters.flatMap(\.lessons)

  /// 클리어 조건 없이 자유롭게 포인터를 연결/해제할 수 있는 샌드박스(Playground) 레슨
  /// `chapters`/`lessons`에는 포함하지 않고, Main 화면의 별도 진입점에서만 참조한다
  ///
  /// id는 챕터 밖 예약 번호대(100~)를 쓴다. `Lesson`은 `id` 기준으로 `Hashable`이고
  /// `MainView`가 값 기반 내비게이션(`navigationDestination(for: Lesson.self)`)을 쓰므로
  /// 실제 레슨과 id가 겹치면 안 된다 (레슨 0 추가로 id 0이 실제 레슨에 넘어갔다)
  static let sandboxLesson = Lesson(
    id: 100,
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
          id: 0,
          title: "변수와 메모리",
          description: "메모리는 번호가 붙은 상자들입니다.\n값이 들어 있는 상자를 눌러 이름·번호·내용을 확인해 보세요.",
          iconName: "shippingbox",
          blueprint: .init(
            seeds: [
              .init(index: 1, type: .value, value: 20, variableName: "age"),
              .init(index: 6, type: .value, value: 100, variableName: "score"),
              .init(index: 10, type: .value, value: 7, variableName: "level")
            ],
            successCondition: .inspectedAll(indices: [1, 6, 10]),
            initialCodeLog: "// 레슨 0: 메모리의 모든 칸에는 번호(주소)가 있어요. 값이 든 상자 3개를 눌러 확인해 보세요."
          ),
          summary: "변수는 이름표가 붙은 상자이고, 그 상자에는 값과 별개로 자기만의 번호(주소)가 있습니다."
        ),
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
          ),
          conceptCard: .init(
            sentences: [
              "레슨 0에서 본 상자에는 저마다 번호가 붙어 있었습니다. 그 번호를 주소라고 부릅니다.",
              "포인터는 값을 복사해 오는 상자가 아니라, 그 값이 어디에 있는지를 적어 두는 상자입니다.",
              "그래서 포인터 칸에는 숫자 대신 `→ 0x700C`처럼 다른 칸의 번호가 들어갑니다.",
              "C로 쓰면 `int *p1 = &target;` 입니다. `*`는 이 상자에 주소가 들어간다는 표시이고, `&`는 주소를 알려 달라는 뜻입니다.",
              "값을 복사하지 않기 때문에, 같은 값을 여러 곳에서 함께 보고 함께 고칠 수 있습니다. 주소를 쓰는 이유가 여기에 있습니다."
            ],
            diagram: .pointerToValue
          ),
          summary: "포인터는 값을 복사해 담는 상자가 아니라, 값이 있는 곳의 번호를 담는 상자입니다."
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
            hintCode: "int **p1 = &ptr1; // ptr1(0x7014)을 가리키는 이중 포인터"
          ),
          conceptCard: .init(
            sentences: [
              "포인터도 메모리 한 칸을 차지합니다. 값이 든 상자와 똑같이 자기 주소를 가집니다.",
              "주소가 있다는 것은, 다른 포인터가 이 칸도 가리킬 수 있다는 뜻입니다.",
              "`ptr1`이 값을 가리키고 `p1`이 `ptr1`을 가리키면, `p1`은 이중 포인터입니다.",
              "C로 쓰면 `int **p1 = &ptr1;` 입니다. `*`가 하나 늘어날 때마다 값에 닿기까지 한 번 더 따라가야 합니다."
            ],
            diagram: .pointerToPointer
          ),
          summary: "포인터도 자기 주소를 가지기 때문에, 다른 포인터가 그 포인터를 가리켜 이중 포인터가 됩니다."
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
          ),
          conceptCard: .init(
            sentences: [
              "포인터가 포인터를 가리킬 수 있으니, 이어 붙이면 길이 됩니다.",
              "`start`에서 출발해 `nodeA`, `nodeB`를 거쳐야 `treasure`에 닿습니다.",
              "각 칸은 다음 칸이 어디에 있는지만 알고 있습니다. 실제 값은 마지막 칸에만 있습니다.",
              "이렇게 이어진 구조를 연결 리스트라고 부릅니다. 이름은 지금 외우지 않아도 괜찮습니다."
            ],
            diagram: .pointerChain
          ),
          summary: "각 칸이 다음 칸의 번호만 알고 있어도, 이어 붙이면 값까지 가는 하나의 길이 됩니다."
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
  /// 그리드에 들어가기 전에 보여줄 개념 카드
  /// 값이 없으면 카드를 띄우지 않는다 (레슨 0은 레슨 자체가 개념 설명이라 카드를 두지 않는다)
  var conceptCard: ConceptCard?
  /// 클리어 알럿에 보여줄 "이번에 배운 것" 한 문장
  /// 개념 카드가 진입 전에 "무엇을 배울 것인가"를 말한다면, 이 문장은 방금 한 조작과 개념을 잇는다.
  /// 값이 없으면 알럿에 본문 없이 제목만 나온다 (샌드박스·Coming Soon 레슨)
  var summary: LocalizedStringResource?
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
  /// `indices`의 슬롯을 모두 탭해 내용을 확인하면 클리어
  /// 포인터가 등장하기 전 단계(레슨 0)처럼 "연결"이 아니라 "관찰"이 목표인 레슨에서 쓴다
  case inspectedAll(indices: [Int])
  /// 클리어 조건 없이 자유롭게 탐험하는 샌드박스 모드
  case sandbox
}

/// 레슨이 전제하는 개념을 그리드에 들어가기 전에 설명하는 카드
/// 배치·판정을 담는 `LessonBlueprint`와 달리 "설명"만 담는다
struct ConceptCard {
  /// 카드 본문. 문장 하나가 한 문단으로 표시된다 (3~5개)
  let sentences: [LocalizedStringResource]
  /// 본문 위에 그릴 도식
  let diagram: Diagram

  /// 개념 카드에 그릴 도식의 종류
  /// 도식은 새 이미지가 아니라 그리드와 같은 슬롯·화살표 표기로 조립한다 (`VISUAL_LANGUAGE.md` §8)
  enum Diagram {
    /// 값 슬롯 하나와, 그 주소를 담아 가리키는 포인터 슬롯 하나
    /// C 언어의 `int *p = &a;`
    case pointerToValue
    /// 값을 가리키는 포인터와, 그 포인터를 다시 가리키는 이중 포인터
    /// C 언어의 `int **pp = &p;`
    case pointerToPointer
    /// 포인터 여러 개가 값까지 순서대로 이어지는 체인
    case pointerChain
  }
}

/// 레슨의 초기 배치와 클리어 조건을 데이터로 표현
struct LessonBlueprint {
  var seeds: [SlotSeed]
  var successCondition: SuccessCondition
  var initialCodeLog: LocalizedStringResource
  /// "힌트 보기" 버튼을 탭했을 때 코드 패널에 일시적으로 보여줄 목표 코드 (정답을 자동 완성하지 않고 힌트만 제공)
  var hintCode: LocalizedStringResource?
}
