# PLAN

## 배경

Pointer Quest는 Swift Student Challenge(SSC) 제출을 위해 4주 일정으로 설계된 "게임" 포맷 앱이었으나 수상하지 못했다. 이제 목표는 App Store 정식 출시이며, 기존 "게임" 포맷 대신 **인터랙티브 학습 도구**로 리포지셔닝한다.

## 문제 진단

- 레슨이 3개뿐이며, 레슨별 초기 배치·성공 조건이 `MemoryGridVM`의 `switch` 문에 하드코딩되어 있어 콘텐츠를 늘릴 때마다 로직 코드를 계속 건드려야 함
- "Mission", "Level Clear! 🎉", 잠금+흔들림 에러 연출 등이 SSC 심사위원 어필용 장치로 설계되어 학습 목적보다 게임 펀치라인에 가까움
- 앱의 진짜 강점(드래그로 "가리킨다" 개념을 체득시키는 인터랙션, 실시간 C 코드 매핑, 화살표 애니메이션)은 게임이 아니라 학습 시뮬레이터로 포지셔닝할 때 훨씬 설득력 있음

## 방향

콘텐츠(레슨) 대량 저작이 아니라, **데이터 기반 구조로 리팩터링하고 학습 도구로 리포지셔닝하는 아키텍처 기반을 마련**하는 것이 우선이다. 신규 레슨(배열, 구조체, malloc/free, 스택/힙 등) 저작은 이 구조 위에서 이후 별도 작업으로 확장한다.

## 이번 범위 (Non-goals 포함)

- 배열/구조체/동적 메모리/스택-힙 등 신규 챕터의 실제 콘텐츠 저작은 제외 (커리큘럼 설계는 별도 협의 → 백로그)
- 앱 이름/브랜딩("Pointer Quest: The Memory Maze") 최종 확정은 이번 리팩터링과 독립적인 결정이므로 제외
- XP/스트릭/리더보드 등 무거운 게이미피케이션은 배제, 완료 체크 표시 정도의 가벼운 동기부여만 유지

## 아키텍처 변경

### 1. Level → Lesson 데이터 모델을 선언형으로 전환

`Core/Lesson.swift`에 레슨의 초기 배치와 성공 조건까지 데이터로 표현한다.

- `Lesson`: `id`, `chapterId`, `title`, `description`, `iconName` + `blueprint: LessonBlueprint`
- `LessonBlueprint`: `slotSeeds: [SlotSeed]`(인덱스별 초기 type/value/pointingTo/isLocked), `successCondition: SuccessCondition`
- `SuccessCondition`: 현재 3개 레슨의 성공 판정 패턴(`anyPointerPointsTo`, `chain`)을 표현하는 enum. 새 패턴이 필요하면 case를 추가하는 방식으로 확장
- `Chapter`: `id`, `title`, `lessons: [Lesson]` — Main 화면에서 챕터 단위로 묶어 보여주기 위한 그룹

`MemoryGridVM`의 `setupLevel`/`checkSuccess`에서 `switch` 분기를 제거하고, 블루프린트를 소비하는 범용 로직으로 교체한다. 기존 3개 레슨(주소 찾기/이중 포인터/체인 연결)의 동작은 100% 동일하게 유지하되 데이터로 표현만 바뀐다.

### 2. Chapter 1개 + 레슨 3개로 재구성, 이후 챕터는 placeholder

- Chapter 1 "주소와 포인터"에 기존 3개 레슨을 그대로 배치
- Chapter 2~5 (이중 포인터 심화 / 배열과 포인터 연산 / 구조체와 포인터 / malloc·free와 스택 vs 힙)는 "Coming Soon" 상태로만 등록

### 3. 게임 카피 → 학습 도구 카피로 톤 조정

- "Mission" → "Lesson", "Level Clear! 🎉" → "Lesson Complete! 🎉" 등 학습 완료를 알리는 문구
- 잠금/에러 시각 효과는 재사용하되, 문구는 왜 틀렸는지 설명하는 학습형 문구로 다듬는다
- "Lv. N" 같은 게임 용어를 "Lesson N" 등으로 조정

### 3-1. 로컬라이제이션 (한국어 기본 / 영어 선택)

- Xcode String Catalog(`Localizable.xcstrings`)를 도입해 앱 전체 사용자 노출 문구를 로컬라이즈한다 (소스 언어 `en` 유지, `ko` 번역 추가)
- `Lesson`/`Chapter`의 `title`/`description`처럼 데이터로 정의된 문구는 `LocalizedStringResource` 타입으로 전환해 카탈로그 기반 번역이 적용되도록 한다. `MemoryGridVM`의 `codeLog`(C 코드 피드백)도 최종적으로는(Task 8 후속) `LocalizedStringResource`로 전환해 로컬라이즈 대상에 포함시켰다 — `int`/`printf` 등 코드 구문 자체는 두 언어 공통으로 영어 유지, `//` 주석만 번역
- 앱 최초 실행 시에는 기기 시스템 언어와 무관하게 한국어를 기본값으로 보여주고, `SettingView`에 언어 선택(한국어/English) UI를 추가해 사용자가 영어로 전환할 수 있게 한다. 전환은 즉시 적용이 아닌 "재시작 필요" 방식으로 구현한다 (Bundle 스위즐링 등 즉시 전환 방식은 채택하지 않음)

### 4. 샌드박스(자유 탐험) 모드 추가

- 성공 조건 없이 자유롭게 포인터를 연결/해제할 수 있는 Playground 모드
- Main 화면에 별도 진입점 카드 추가

### 5. 진행 상황 저장 (가벼운 동기부여)

- 완료한 레슨 id를 `UserDefaults` 기반으로 저장, 카드에 체크마크만 표시 (XP/포인트 등 추가 수치 없음)

### 6. Main 화면 카드 페이징 → 챕터별 세로 리스트 재설계

- Chapter 2~5 placeholder 추가로 카드 개수가 3개 → 7개로 늘어났고, 향후 각 챕터에 실제 레슨이 계속 추가될 예정이라 항목 수는 계속 늘어남. 기존 `PagingCardsScrollView`는 `TabView(.page)`가 아니라 커스텀 `DragGesture` 기반 캐러셀이었고 치수 계산(`screenWidth - 100`, `cardWidth / 2.5 * 3.5` 등)도 특정 화면 크기를 가정한 하드코딩이라 iPhone SE~Pro Max에서 카드 잘림·여백 붕괴 위험이 있었음
- Apple HIG는 가로 페이징을 소수의 동등한 가치를 가진 항목(온보딩, 에디토리얼 피처)에 권장하고, 챕터-레슨처럼 계층을 가진 콘텐츠 탐색에는 세로 스크롤 리스트를 권장함. 이에 따라 가로 캐러셀을 걷어내고 챕터를 `Section`으로 그룹핑한 세로 `List`(insetGrouped)로 전면 재설계 — 최소 터치 타겟, Dynamic Type, VoiceOver, 다크모드 배경을 시스템이 기본 제공하도록 함
- iPad는 이번 범위에서 별도 적응형(멀티컬럼) 레이아웃까지는 만들지 않고 "깨지지 않는" 수준만 보장

### 7. 로컬라이제이션 소스 언어를 한국어로 전환

- 현재 코드 내 `Text()`/`Lesson`·`Chapter`의 문자열 리터럴은 영어로 작성되어 있고 `Localizable.xcstrings`에서 `ko`를 번역으로 추가하는 구조. 하지만 이 앱의 실질적 기본/타깃 언어는 한국어이므로, 소스 문자열 자체를 한국어로 두고 영어를 번역으로 관리하는 편이 실제 개발 흐름과 더 맞음 (이미 `Chapter.title`에는 이 방식이 부분적으로 적용되어 있었음)
- 앱 전체 사용자 노출 문구의 코드 리터럴을 한국어로 전환하고, 기존 영어 문구는 `Localizable.xcstrings`의 `en` 로컬라이제이션으로 이관해 영어 사용자에게 보이는 내용은 동일하게 유지

## 백로그 (다음 단계로 분리)

- Chapter 2~5 실제 레슨 콘텐츠 저작 (커리큘럼 상세는 별도 협의)
- 앱 이름/브랜딩/아이콘 재검토
- App Store 심사 대비 항목 점검 (개인정보처리방침, 스크린샷, 지원 언어 등)
