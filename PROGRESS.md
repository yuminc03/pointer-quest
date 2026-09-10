# PROGRESS
세부 작업 항목은 [TODO.md](./TODO.md), 전체 방향은 [PLAN.md](./PLAN.md) 참고.

## 현재 상태 (2026-09-10 기준)
- Task 1~23·25·26 모두 구현·검증·`develop` 병합 완료 (최신 병합 커밋 `57a8bad`)
- **로컬 feature 브랜치가 두 개 열려 있다.** Task 24의 `feature/app-store-metadata`(커밋 2개)와 Task 27의 `feature/sandbox-variable-names`(커밋 3개)다. Task 24를 찍다가 Task 27을 발견해 먼저 닫는 중이라 이렇게 됐다
- **1.0 출시 전 항목 1~3번 완료.** 남은 것은 4번 App Store 심사 대비 하나이며, 착수 전 결정 4건을 2026-09-09에 확정하고 Task 20~27로 쪼갰다
- **Task 27이 사용자 검증 대기이고, 그것을 병합하면 Task 24만 남는다**
- **사용자 잔여 작업 없음** — Notion 두 페이지의 본문 붙여넣기와 공유 권한 낮추기가 2026-09-10 끝났다
- Task별 상세 내역은 이 문서의 각 "Task N 진행 상황/완료" 섹션 참고

## Task 1~2 완료 및 초기 검증
- `feature/lesson-data-model` (Task 1), `feature/blueprint-driven-vm` (Task 2), `feature/learning-tone-copy` (Task 3), `feature/sandbox-mode` (Task 4), `feature/lesson-progress-tracking` (Task 5) 모두 `develop`에 병합 완료 (병합 커밋 `42efd7b`, `37ba5ce`, `41d01af`, `fc06f24`), `origin/develop`에 푸시 완료
- 병합 완료된 로컬 feature 브랜치는 매번 삭제 완료
- 다음은 `develop`에서 `feature/chapter-placeholders` (Task 6) 브랜치를 분기해 착수 예정
- `Level` → `Lesson` 타입/파일 리네임, `SlotSeed`/`SuccessCondition`/`LessonBlueprint`/`Chapter` 타입 추가, 기존 3레슨의 Chapter 1 마이그레이션은 Task 1에서 완료
- `MemoryGridVM.setupLevel`을 `Lesson.blueprint.seeds` 기반 범용 로직으로 교체 완료 (`switch level.id` 제거, `SlotSeed`를 순회하며 슬롯 배치)
- `MemoryGridVM.checkSuccess`를 `Lesson.blueprint.successCondition` 기반 범용 로직으로 교체 완료 (`switch currentLesson.id` 제거, `.anyPointerPointsTo`/`.chain` case 처리)
- `handleDrop`의 잠금 슬롯 체크도 `currentLesson.id == 2` 하드코딩 대신 `slots[targetIndex].isLocked` 범용 체크로 변경
- 사용하지 않던 `initializeMemory()` 죽은 코드 제거
- 빌드 재검증 완료 (`xcodebuild ... build` → BUILD SUCCEEDED)
- 코드 레벨 검증 완료: `switch level.id`/`switch currentLesson.id` 잔재 없음, `setupLevel`(:221-243)/`checkSuccess`(:246-263)/`handleDrop`의 잠금 체크(:117-123) 모두 블루프린트 기반 범용 로직으로 구현 확인. 기존 3레슨(`Core/Lesson.swift`)의 seed 배치·successCondition이 리팩터링 이전 하드코딩 의도와 정확히 대응함을 확인
  - Lesson 1: `.anyPointerPointsTo(3)` — 주소 찾기
  - Lesson 2: locked index 7 + `.anyPointerPointsTo(5)` — 이중 포인터/징검다리
  - Lesson 3: `.chain([0,5,11,15])` — 체인 연결
- 시뮬레이터(iPhone 16) 설치·실행 확인: 앱이 크래시 없이 정상 구동되고 홈 화면·Lesson 1 카드가 정상 렌더링됨을 스크린샷으로 확인. 단, 이 환경에서는 좌표 기반 GUI 자동화 도구(idb/XCUITest 등)가 없어 드래그 기반 인터랙션(포인터 연결)의 자동 재현은 수행하지 못함 — 코드 레벨 검증으로 논리적 동일성은 확보했으나, 실제 드래그 조작 검증은 사용자의 수동 플레이 테스트를 권장

## Task 3 완료 (`feature/learning-tone-copy`)
게임 카피 → 학습 도구 카피 전환 + 로컬라이제이션(한국어 기본/영어 선택) 도입 완료. 세부 계획은 `TODO.md`/`PLAN.md` 참고.

- `Core/Lesson.swift`의 `initialCodeLog` "Level 1/2/3" → "Lesson 1/2/3" 텍스트 수정
- `MemoryGridVM.swift`의 잠금/에러/완료 `codeLog` 문구를 설명형 학습 톤으로 변경 ("Access Denied"/"Security Violation"/"Level Clear!" 제거)
- `MissionHeaderView.swift` → `LessonHeaderView.swift` 리네임 (파일명·구조체명·"Mission"→"Lesson" 라벨), `MemoryGridView.swift`의 alert 타이틀도 "Lesson Complete! 🎉"로 변경
- `LessonCard.swift`의 "Lv. N"/"LEVEL N" → "Lesson N", `OnboardingView.swift`의 "Level" 잔존 표현 → "Lesson" 통일
- `Localizable.xcstrings` String Catalog를 프로젝트에 추가 (`project.pbxproj` 수동 편집 — 파일 시스템 동기화 그룹을 쓰지 않는 구식 형식이라 파일 참조·Resources 빌드 페이즈·`knownRegions`에 `ko`를 직접 추가, 매 단계 빌드로 검증)
- `Lesson`/`Chapter`의 `title`/`description`을 `LocalizedStringResource`로 전환해 데이터 기반 문구도 카탈로그 번역이 적용되도록 함 (`Hashable`은 `id` 기준으로 직접 구현). `codeLog`는 계획대로 영어 고정, 로컬라이즈 제외
- 앱 전체(메인/웰컴/설정/온보딩/레슨 헤더/그리드/카드) 사용자 노출 문구에 `ko` 번역 채움. `LessonCard`의 `"...".uppercased()`가 비-로컬라이즈 `Text(String)` 오버로드를 타던 버그를 `.textCase(.uppercase)`로 함께 수정
- `App/AppLanguage.swift` 신설: 최초 실행 시 한국어를 기본값으로 강제 적용(`MyApp.init()`에서 호출), `SettingView`에 언어 선택(한국어/English) UI + "재시작 필요" 안내 추가
- 매 커밋마다 `xcodebuild ... build` → BUILD SUCCEEDED 확인, 최종 grep으로 "Mission"/"Level Clear"/"Lv."/"Access Denied"/"Security Violation" 잔존 없음 확인
- 사용자가 Xcode에서 직접 빌드·시뮬레이터 테스트하는 과정에서 `Localizable.xcstrings`가 재추출되며 초기 조사에서 빠졌던 문구 발견: `AppView.swift`의 탭 라벨 "Home", 튜토리얼 재확인 안내 alert, `MemoryItem.swift`의 빈 슬롯 "-" 플레이스홀더 → ko 번역 추가로 보완
  - `LessonHeaderView.swift`에도 `LessonCard`와 동일한 `Text("...".uppercased())` 비-로컬라이즈 버그가 남아있던 것을 추가로 발견해 `.textCase(.uppercase)`로 수정
  - `SWIFT_EMIT_LOC_STRINGS` 빌드 설정이 꺼져 있어 Xcode가 컴파일러 기반 정밀 추출 대신 약한 휴리스틱 스캔을 쓰면서 "Lesson %@" 같은 잘못된 포맷 스펙 항목이 생성된 것을 확인, 타깃 Debug/Release 설정에 `SWIFT_EMIT_LOC_STRINGS = YES` 추가로 근본 원인 해결

## Task 4 진행 상황 (`feature/sandbox-mode`)
샌드박스(Playground) 모드의 핵심 3개 체크리스트 항목 구현 완료. 기존 블루프린트 기반 아키텍처(`Lesson`/`SuccessCondition`)를 그대로 재사용하는 최소 변경 방식으로 설계 — `MemoryGridVM`/`MemoryGridView`의 드래그·역참조·에러 로직은 전혀 수정하지 않았다.

- `SuccessCondition`에 `.sandbox` 케이스 추가, `MemoryGridVM.checkSuccess()`가 해당 케이스에서는 클리어 판정을 하지 않도록 처리 (커밋 `d423e21`)
- `LessonData.sandboxLesson` 추가: `seeds: []`(16개 슬롯 모두 빈 상태로 시작), `successCondition: .sandbox`인 별도 `Lesson` 상수. 기존 `chapters`/`lessons` 배열에는 포함하지 않아 페이징 카드 목록·챕터 개수 등에 영향 없음 (커밋 `800c18d`)
- `LessonHeaderView`: `successCondition == .sandbox`일 때 상단 라벨을 "Lesson" 대신 "Playground"로 표시 (커밋 `557c331`)
- `MainView`: 기존 페이징 카드/"이어서 학습하기" 버튼과 별개로, `LessonData.sandboxLesson`으로 진입하는 독립된 카드(`SandboxEntry`)를 하단에 추가. 기존 `.navigationDestination(for: Lesson.self)` 라우트를 그대로 재사용해 `MemoryGridView` 쪽 변경 없이 연결 (커밋 `eae267c`)
- "Playground"/샌드박스 설명문/카드 부제 3개 문구에 대한 `ko` 번역을 `Localizable.xcstrings`에 추가 (커밋 `77c63f4`)
- 매 커밋마다 해당 파일 변경분만 격리한 상태로 `xcodebuild ... build` → BUILD SUCCEEDED 확인 (`git stash push --keep-index -- <path>`로 다른 파일 변경을 임시 대피시키는 방식)
- 시뮬레이터(iPhone 16, iOS 18.5) 설치·실행 확인: Main 화면 하단에 "플레이그라운드" 카드(마법봉 아이콘, 노란색 그라데이션, "목표 없이 자유롭게 탐험해 보세요." 부제)가 의도대로 렌더링됨을 스크린샷으로 확인
- AppleScript(`System Events`)로 카드 탭을 자동화해 그리드 화면 전환까지 확인을 시도했으나, Simulator 창의 좌표계(포인트/픽셀 배율, 타이틀바 높이)를 신뢰성 있게 계산하지 못해 탭이 반영되지 않음 — Task 3 때와 동일한 한계(이 환경에 idb/XCUITest 등 좌표 기반 GUI 자동화 도구 없음)로, 그리드 화면 진입 후 실제 드래그 동작 확인은 수행하지 못함. 다만 `MemoryGridView`/`MemoryGridVM`은 이번 작업에서 코드 변경이 없고 기존 3개 레슨에서 이미 정상 동작이 검증된 경로를 그대로 타므로 논리적 위험은 낮음
- 사용자가 Xcode/시뮬레이터에서 직접 후속 검증 3건을 수행: 클린 빌드 후 `Localizable.xcstrings` `STALE` 배지 해소 확인, 시뮬레이터 언어 표시 정상 확인, Playground 화면 수동 드래그 테스트(포인터 연결/해제/리셋, "Lesson Complete" 알림 미표시) 모두 이상 없음으로 확인 — Task 4 체크리스트 전 항목 완료
- 클린 빌드 검증 과정에서 `OnboardingView.section(text:)`가 `String` 파라미터를 받아 `Text(String)` 비-로컬라이즈 오버로드를 타던 버그를 추가로 발견, `LocalizedStringKey`로 변경해 수정 (`LessonCard`/`LessonHeaderView`에서 Task 3 때 발견한 것과 동일 유형의 버그, 커밋 `5428a85`). 온보딩 3개 문구의 `extractionState: "stale"`도 재추출로 해소됨을 확인

## Task 4 완료 (`feature/sandbox-mode`)
샌드박스(Playground) 모드 구현 및 후속 검증까지 완료. 세부 구현 내역은 위 "Task 4 진행 상황" 참고. 사용자 수동 검증(클린 빌드 STALE 배지 해소, 시뮬레이터 언어 표시, Playground 드래그 인터랙션) 완료로 `develop` 병합 조건 충족.

- `develop`에 `--no-ff` 병합 완료 (병합 커밋 `41d01af`), 병합 직후 `xcodebuild ... build` → BUILD SUCCEEDED 재검증
- `origin/develop`에 push 완료 (`37ba5ce..41d01af`), 로컬 `feature/sandbox-mode` 브랜치 삭제

## Task 5 진행 상황 (`feature/lesson-progress-tracking`)
레슨 완료 진행 상황 저장 및 카드 체크마크 표시 핵심 2개 체크리스트 항목 구현 완료. 기존 `MemoryGridVM.finishLevel()`/`LessonCard` 흐름에 최소 변경만 추가하는 방식으로 설계.

- `Core/LessonProgressStore.swift` 신설: `@MainActor final class LessonProgressStore: ObservableObject`, `UserDefaults` 키 `completedLessonIds`에 `[Int]`로 저장하고 내부적으로 `Set<Int>`(`@Published private(set) var completedLessonIds`)로 관리. `AppLanguage.swift`와 달리 View가 완료 상태 변경을 실시간으로 관찰해야 해서(카드 체크마크 즉시 갱신) `ObservableObject` + 싱글턴(`.shared`)으로 설계
- `project.pbxproj`에 `LessonProgressStore.swift` 파일 참조 수동 추가 (파일 시스템 동기화 그룹을 쓰지 않는 구식 포맷이라 `PBXBuildFile`/`PBXFileReference`/`Core` 그룹/`Sources` 빌드 페이즈 4곳에 직접 추가, `Localizable.xcstrings` 추가 때와 동일한 절차)
- `MemoryGridVM.finishLevel()`에서 `LessonProgressStore.shared.markCompleted(currentLesson.id)` 호출 추가. 샌드박스 레슨(`id: 0`)은 `successCondition: .sandbox`라 `finishLevel()` 자체가 호출되지 않아 별도 예외 처리 없이도 진행 기록에서 자연히 제외됨
- `LessonCard`에 `@ObservedObject private var progressStore = LessonProgressStore.shared` 추가, `TopSection`의 "Lesson N" 라벨 앞에 완료 시 `checkmark.circle.fill` 아이콘을 조건부로 표시
- 체크마크 아이콘에 `Text("Completed")` 기반 accessibility label 추가, `Localizable.xcstrings`에 `ko` 번역("완료") 추가
- `xcodebuild ... build` → BUILD SUCCEEDED 확인

## Task 5 완료 (`feature/lesson-progress-tracking`)
레슨 완료 진행 상황 저장 및 카드 체크마크 표시 구현 및 검증까지 완료. 세부 구현 내역은 위 "Task 5 진행 상황" 참고. 사용자가 시뮬레이터에서 직접 검증(레슨 클리어 후 카드 체크마크 표시, 앱 재실행 후에도 완료 상태 유지) 완료로 `develop` 병합 조건 충족.

- `develop`에 `--no-ff` 병합 완료 (병합 커밋 `fc06f24`), 병합 직후 `xcodebuild ... build` → BUILD SUCCEEDED 재검증
- `origin/develop`에 push 완료 (`41d01af..fc06f24`), 로컬 `feature/lesson-progress-tracking` 브랜치 삭제

## Task 6 진행 상황 (`feature/chapter-placeholders`)
Chapter 2~5 placeholder 등록 및 Coming Soon UI 핵심 2개 체크리스트 항목 구현 완료. Task 4(샌드박스 모드)에서 검증한 "새 타입을 만들지 않고 기존 `Lesson`에 필드를 추가해 재사용"하는 최소 변경 패턴을 그대로 따랐다.

- `Core/Lesson.swift`: `Lesson`에 `var isComingSoon: Bool = false` 필드 추가(기존 4개 `Lesson.init` 호출부는 기본값 덕분에 무수정), `chapters`에 Chapter 2~5(이중 포인터 심화/배열과 포인터 연산/구조체와 포인터/malloc·free와 스택 vs 힙) 추가. 각 챕터에는 `comingSoonLesson(id:title:)` 헬퍼로 만든 placeholder 레슨 1개씩 포함(`id` 4~7, 기존 1~3과 전역 유일성 유지). `successCondition`은 실제로 열람되지 않으므로 새 케이스 없이 기존 `.sandbox`를 재사용 (커밋 `c5f390d`)
- `PagingCardsScrollView.swift`: `colors[$0]`이 3개짜리 리터럴 배열을 직접 인덱싱해 카드가 3개를 넘으면 크래시하던 부분을 `colors[$0 % colors.count]`로 수정 — Chapter 2~5 카드 추가로 총 7개 카드가 되면서 반드시 선행되어야 했던 수정 (커밋 `b09fb4e`)
- `LessonCard.swift`: `isComingSoon`이면 완료 체크마크/"Lesson N" 라벨 대신 "Coming Soon" 배지를, 기존 컬러 그라데이션 대신 회색 톤 그라데이션을 표시하도록 분기 (커밋 `a4f4211`)
- `MainView.swift`: `ContinueButton`에서 현재 페이지 레슨이 `isComingSoon`이면 `NavigationLink` 대신 탭 되지 않는 회색 "Coming Soon" 버튼으로 대체해 실제 콘텐츠 없는 `MemoryGridView` 진입을 차단 (커밋 `4244fe7`)
- `Localizable.xcstrings`: Chapter 2~5 제목 4개(한글 키 + `en` 번역) 및 "Coming Soon"/"Coming soon in a future update." 문구의 `ko` 번역 추가. `SWIFT_EMIT_LOC_STRINGS` 설정 덕분에 새 문구가 자동으로 카탈로그에 빈 항목으로 추출된 것을 확인 후 값을 채움 (커밋 `1b0c0dc`)
- 매 커밋마다 논리 단위를 분리해 `git stash push --keep-index`로 다른 파일 변경을 격리한 상태로 `xcodebuild ... build` → BUILD SUCCEEDED 확인 (Task 4/5와 동일한 패턴)
- 시뮬레이터(iPhone 16) 설치 시도 중 여러 개의 stale `DerivedData` 캐시 폴더가 있어 잘못된(구버전 기본 템플릿) 빌드가 먼저 설치되는 문제 발견, `-showBuildSettings`로 정확한 `TARGET_BUILD_DIR`을 확인해 올바른 최신 빌드로 재설치 후 온보딩 화면이 정상 렌더링됨을 스크린샷으로 확인
- 사용자가 이후로는 시뮬레이터 인터랙션 테스트(카드 스와이프, Coming Soon 버튼 탭 등)를 직접 수행하고 결과를 공유하기로 함 — Coming Soon 카드/비활성 버튼의 실제 동작 확인은 사용자의 수동 테스트 대기 중

## Task 6 완료 (`feature/chapter-placeholders`)
Chapter 2~5 placeholder 등록 및 Coming Soon UI 구현 및 검증까지 완료. 세부 구현 내역은 위 "Task 6 진행 상황" 참고. 사용자가 시뮬레이터에서 직접 검증(Coming Soon 카드 7개 정상 렌더링, 비활성 Continue 버튼 동작, 기존 레슨 1~3/Playground 회귀 없음) 완료로 `develop` 병합 조건 충족.

- `develop`에 `--no-ff` 병합 완료 (병합 커밋 `31b4b85`), 병합 직후 `xcodebuild ... build` → BUILD SUCCEEDED 재검증
- `origin/develop`에 push 완료 (`850b0ef..31b4b85`), 로컬 `feature/chapter-placeholders` 브랜치 삭제

## Task 7 진행 상황 (`feature/card-paging-redesign`)
조사 결과 원래 범위(치수 하드코딩 반응형 수정)보다 근본 문제가 컸다: `PagingCardsScrollView`가 `TabView(.page)`가 아니라 `GeometryReader` + `LazyHStack` + 커스텀 `DragGesture`로 관성/스프링 애니메이션까지 직접 구현한 캐러셀이었고, 카드 너비/높이가 `screenWidth - 100`, `cardWidth / 2.5 * 3.5` 등으로 하드코딩되어 있었다. Chapter 2~5 placeholder로 카드가 3장 → 7장이 되었고 백로그상 계속 늘어날 예정이라, Apple HIG가 권장하는 대로(가로 페이징은 소수의 동등 항목용, 계층적 콘텐츠는 세로 리스트용) **가로 캐러셀을 걷어내고 챕터 섹션으로 그룹핑한 세로 `List`로 전면 재설계**하기로 사용자와 합의(`AskUserQuestion`으로 방향 확정: 챕터별 세로 리스트, iPad는 "깨지지만 않게" 수준). 계획은 `/Users/chuyumin/.claude/plans/todo-md-plan-md-snappy-dusk.md`에 저장.

- `PointerQuest/Scene/Main/Entity/PagingCardsScrollView.swift` 삭제 (커스텀 드래그 캐러셀 전체 제거)
- `LessonCard.swift` → `LessonRow.swift`로 리네임 + 구조체명도 `LessonCard` → `LessonRow`로 변경, 카드형 레이아웃(풀사이즈 그라데이션 배경)을 리스트 행 레이아웃(44×44 원형 아이콘 칩 + 제목/설명 + 완료 체크마크/Coming Soon 라벨)으로 재작성. `LessonProgressStore.shared.isCompleted(_:)`, `Image.size(_:)` 등 기존 유틸은 그대로 재사용 (커밋 `5cf9d8a`)
- `MainView.swift`: `pageIndex`/`ContinueButton`/`PageIndicator`/`Cards` 제거, `List(insetGrouped)` 안에 `LessonData.chapters`를 챕터별 `Section`으로 순회하며 `LessonRow` 배치. 일반 레슨은 `NavigationLink(value: lesson)`, Coming Soon은 링크 없이 표시. 기존 `.navigationDestination(for: Lesson.self)` 라우트 그대로 재사용. 챕터별 아이콘 그라데이션은 `PagingCardsScrollView`에 있던 3세트 팔레트를 챕터 index 기준으로 순환 배정(레슨 단위 → 챕터 단위로 변경). `List` 안의 `NavigationLink`가 자동으로 disclosure chevron을 그려주므로 기존에 수동으로 그리던 `chevron.right`는 제거 (커밋 `5cf9d8a`)
- `PointerQuest/DesignSystem/Component/PageControl.swift`(페이지 도트 인디케이터) 삭제 — 세로 리스트로 전환되며 더 이상 참조되지 않는 죽은 코드가 되어 정리 (커밋 `3d7b7d5`)
- 코드 변경 코드 스타일은 기존 컨벤션을 따름: 파라미터 없는 섹션 뷰는 `private extension` 안 대문자 계산 프로퍼티(`Title`, `SandboxEntry`), 파라미터가 있는 헬퍼는 소문자 함수(`lessonRow(lesson:colors:)`) — `PagingCardsScrollView`의 기존 `lessonCard(lesson:proxy:colors:)` 패턴과 동일하게 맞춤
- `project.pbxproj`는 파일시스템 동기화 그룹을 쓰지 않는 구식 포맷이라 파일 삭제/리네임마다 `PBXBuildFile`/`PBXFileReference`/그룹 참조/`Sources` 빌드 페이즈를 수동으로 맞춰 편집 (Task 3/5/6과 동일 절차)
- 각 커밋 전 `xcodebuild ... build` → BUILD SUCCEEDED 확인, `grep`으로 `PagingCardsScrollView`/`LessonCard`/`PageControl` 잔존 참조 없음 확인
- 시뮬레이터 인터랙션·반응형 레이아웃(iPhone SE~Pro Max) 검증은 사용자가 Xcode/시뮬레이터에서 직접 수행하기로 함

## Task 7 완료 (`feature/card-paging-redesign`)
카드 페이징 → 챕터별 세로 리스트 재설계 구현 및 검증까지 완료. 세부 구현 내역은 위 "Task 7 진행 상황" 참고. 사용자가 iPhone 17 시뮬레이터에서 직접 검증(레이아웃 정상 표시, 이상 없음) 완료로 `develop` 병합 조건 충족.

- `TODO.md` Task 7 체크리스트 2개 항목을 완료로 반영 (원래 "HIG 재검토/반응형 처리"였던 범위가 조사 과정에서 "가로 캐러셀 → 세로 리스트 전면 재설계"로 확장되었음을 체크리스트에 함께 기록)
- `develop`에 `--no-ff` 병합 완료 (병합 커밋 `a9e83e0`), 병합 직후 `xcodebuild ... build` → BUILD SUCCEEDED 재검증
- `origin/develop`에 push 완료 (`7ad05b4..a9e83e0`), 로컬 `feature/card-paging-redesign` 브랜치 삭제

## Task 8 후속 (`codeLog` 실제 로컬라이즈 전환)
Task 3 당시 "`codeLog`는 C 코드 관례상 영어로 고정, 로컬라이즈 제외"로 결정했던 부분을 사용자 요청으로 재검토. 처음에는 `//` 주석만 한국어 리터럴로 바꿨으나, `codeLog`가 `Text(String)`으로 렌더링되고 있어 `Localizable.xcstrings`에 전혀 걸리지 않는다는 점(=번역을 채워도 적용 안 됨, 앱 언어 설정과 무관하게 항상 같은 문구로 고정)을 사용자가 지적. 확인 후 실제로 앱 언어를 따르도록 구조를 바꾸는 방향으로 재작업.

- `Core/Lesson.swift`: `LessonBlueprint.initialCodeLog` 타입을 `String` → `LocalizedStringResource`로 변경 (`Lesson.title`/`description`과 동일한 방식). `LessonBlueprint`는 이 변경으로 `Hashable` 자동 합성이 깨졌는데(`LocalizedStringResource`가 `Hashable` 미준수), 실제로는 `Lesson`(자체 `id` 기준 수동 `Hashable`)의 저장 프로퍼티로만 쓰이고 `Hashable` conformance가 어디서도 요구되지 않아 `LessonBlueprint`에서 `Hashable` 자체를 제거
- `Scene/Quest/MemoryGridVM.swift`: `codeLog` 프로퍼티 타입을 `LocalizedStringResource`로 변경. 이중 포인터 케이스(`handleTap` Case B)에서 `explicitLog`라는 중간 `String` 변수에 완성된 문구를 조립한 뒤 다시 끼워 넣던 구조를 제거하고, 분기마다 완성된 `codeLog` 리터럴을 직접 작성하도록 재구성 — 그렇지 않으면 바깥 템플릿만 번역되고 안에 끼워진 조각은 계속 한국어로 하드코딩된 채 남는 문제가 있었음
- `DesignSystem/Component/CodeFeedbackView.swift`: `code` 프로퍼티 타입을 `String` → `LocalizedStringResource`로 변경
- `Localizable.xcstrings`에 새 키 19개(주석이 포함된 `codeLog` 문구만 대상, 코드만 있고 자연어가 없는 문구는 언어 무관이라 제외)를 JSON으로 직접 추가하고 `en` 번역 채움 — 원래 Task 3~4에서 사용하던 영어 원문을 그대로 복원해 매칭
- `printf("%d", ...)`/`printf("%p", ...)` 코드 로그 3곳: 리터럴 `%d`/`%p`가 `LocalizedStringResource`의 실제 보간(`%lld`/`%@`)과 공존하면 포맷 플레이스홀더로 오인될 수 있다고 판단해 처음엔 소스에 `%%d`/`%%p`로 직접 이스케이프. 그런데 이후 빌드 과정에서 Xcode의 컴파일러 기반 문자열 추출이 실제로 동작하는 것을 확인했는데(= CLI 빌드도 결국 `.xcstrings`에 자동 동기화됨, 이전 Task들에서 "CLI로는 추출 안 됨"이라 판단했던 것은 틀린 결론이었고 단지 지연/비동기적으로 반영되는 것이었음), 이 추출기가 리터럴 `%`를 자체적으로 한 번 더 이스케이프하면서 소스의 `%%d`가 카탈로그에는 `%%%%d`로 중복 이스케이프되어 깨진 항목이 생성됨을 발견. 소스는 원래대로 단일 `%d`/`%p`로 되돌리고(이스케이프는 추출기가 처리), 잘못 생성된 중복 카탈로그 항목 2개를 제거
- `xcodebuild ... build` → BUILD SUCCEEDED 확인 (각 단계마다 반복 검증)
- 사용자가 시뮬레이터에서 직접 검증 (2026-07-29): `printf %d/%p` 깨짐 등은 재현되지 않았으나, 새로운 문제 발견 — `int *p = &target;`처럼 포인터 기호 `*`가 포함된 codeLog 일부에서 `&target` 같은 뒷부분 텍스트가 화면에 표시되지 않음. `codeLog`가 `LocalizedStringResource`로 바뀌며 `Text`가 마크다운을 파싱하게 됐는데, C 코드의 `*`/`**`(포인터 선언·역참조 기호)가 마크다운 강조 구문(`*이탤릭*`, `**볼드**`)으로 오인됐을 가능성이 유력함. 사용자 요청에 따라 지금 당장 수정하지 않고 `TODO.md` 백로그에 기록만 해둠 — 원인 조사·수정은 별도 작업으로 진행 예정

## Task 8 완료 (`feature/localization-source-swap`)
로컬라이제이션 소스 언어 한국어 전환 + `codeLog` 실제 로컬라이즈 전환까지 완료. `codeLog` 마크다운 파싱 버그(위 "Task 8 후속" 참고)는 미해결 상태이지만, 사용자 판단으로 우선 병합하고 별도 브랜치에서 후속 수정하기로 함.

- `develop`에 `--no-ff` 병합 완료 (병합 커밋 `1072d46`), 병합 직후 `xcodebuild ... build` → BUILD SUCCEEDED 재검증
- `origin/develop`에 push 완료 (`2da7f8c..1072d46`), 로컬 `feature/localization-source-swap` 브랜치 삭제

## Task 9 진행 상황 (`feature/lesson-grid-ux-improvements`)
2026-07-29 사용자가 "처음 앱을 써보는 사람" 시점에서 4가지 UX 우려(사용법을 모름/빨간 흔들림이 오답처럼 느껴짐/화살표만으론 포인터 개념 부족/코드 패널이 좁고 문법 강조 없음)를 제기해 착수. 세부 배경·진단·결정 근거는 `PLAN.md`의 "Task 9: 그리드 인터랙션 UX 개선" 참고, 실행 계획은 `/Users/chuyumin/.claude/plans/i-m-concerned-about-whether-hashed-pinwheel.md`에 저장.

- 서브에이전트 3개로 온보딩/구조, 에러(`isError`) 트리거, 코드 패널 구현을 병렬 조사한 뒤 핵심 파일을 직접 읽어 확인
- `AskUserQuestion`으로 방향 확정: 레슨 2 "Lock" 메커닉은 완전 제거(실제 C 시맨틱과 안 맞고 빨간 흔들림이 오답처럼 느껴지는 근본 원인이라는 사용자 판단) 후 논블로킹 힌트로 전환, 온보딩은 그리드 화면 내 실사용 맥락 힌트 추가, 포인터 이해도는 레슨 1 범위에서 "주소 vs 값" 구분 보강, 코드 패널은 마크다운 버그와 함께 개편
- `develop`에서 `feature/lesson-grid-ux-improvements` 브랜치 분기
- Task A 구현: `PointerQuest/DesignSystem/Component/CCodeHighlighter.swift` 신설(`//` 주석/C 키워드/문자열 리터럴 채색 유틸리티), `CodeFeedbackView.swift`에서 `Text(code)`를 `Text(CCodeHighlighter.highlight(String(localized: code)))`로 교체해 `LocalizedStringResource`의 자동 마크다운 파싱 경로를 우회. `.fixedSize(horizontal: false, vertical: true)` 추가로 여러 줄 표시 보장
- `project.pbxproj`에 `CCodeHighlighter.swift` 등록 완료 — 이 프로젝트는 파일시스템 동기화 그룹을 쓰지 않는 구식 포맷이라 `PBXBuildFile`/`PBXFileReference`/`Component` 그룹 children/`Sources` 빌드 페이즈 4곳에 기존 `Arrow.swift`/`CodeFeedbackView.swift`와 동일한 패턴으로 수동 추가 (Task 3/5/6/7과 동일 절차). `plutil -lint`로 pbxproj 문법 확인, `xcodebuild -scheme PointerQuest -destination 'generic/platform=iOS Simulator' build` → BUILD SUCCEEDED 확인
- 사용자가 시뮬레이터에서 직접 확인하는 과정에서 색상 대비 문제 2건 발견 및 수정: (1) 키워드가 아닌 일반 코드/기호(`*`, `;`, `=` 등)에 색을 지정하지 않았더니 `Text(AttributedString)`이 `.foregroundStyle(.white)` 뷰 수정자를 따르지 않고 시스템 라이트/다크 모드에 따라 바뀌는 기본 라벨 색(라이트 모드에서 검정)을 써서 고정 어두운 배경 위에서 텍스트가 안 보임 → `flushToken()`/구두점 처리에 명시적으로 `.white` 지정. (2) 주석 색으로 썼던 `.secondary`도 동일하게 시스템 모드에 따라 바뀌는 색이라 라이트 모드에서 잘 안 보임 → `.white.opacity(0.5)` 고정값으로 변경. `Color(.main)`(키워드 색)은 `Colors.xcassets/Main.colorset`에 라이트/다크 variant 없이 고정 RGB로 정의돼 있어 동일 문제 없음을 확인
- 사용자 피드백으로 색상 2건 추가 조정: 주석 색을 `.white.opacity(0.5)` → `.green`(터미널 스타일)으로, `CodeFeedbackView`의 왼쪽 `chevron.right` 프롬프트 아이콘을 `Color(.green)` → `.white`로 변경
- 사용자가 시뮬레이터에서 직접 검증(마크다운 버그 재현 안 됨, 문법 강조 정상 표시) 완료, `TODO.md`에 검증 완료 반영 (`5126cad`)
- Task B 구현: `PointerQuest/Scene/Quest/Entity/GridInteractionHintOverlay.swift` 신설 — 소스 슬롯(index 8, 포인터) ↔ 타겟 슬롯(index 3, 값) 사이를 오가는 `hand.draw.fill` 아이콘 애니메이션(터치 통과)과 "이 슬롯을 드래그해서 저 주소 위에 놓아보세요" 안내 말풍선 + 닫기 버튼으로 구성. 코드 스타일은 사용자가 직접 `private extension` + 대문자 계산 프로퍼티(`HandIcon`/`CalloutBubble`) 형태로 정리(`OnboardingView`/`MainView` 등 기존 컨벤션과 동일)
- `MemoryGridView.swift` 연동: `@AppStorage("hasSeenGridHint")`로 앱 전체 최초 1회만 노출. 기존 `ArrowDrawLayer`가 쓰던 `overlayPreferenceValue`/`GeometryReader` 블록의 `frames` 딕셔너리를 재사용해, 레슨 1이고 아직 힌트를 안 본 경우에만 오버레이 표시. `MemoryGridVM`에는 힌트 관련 로직을 섞지 않고, 뷰 레벨에서 `vm.slots[8].pointingTo`가 `nil → non-nil`로 바뀌는 순간(=첫 드래그 완료)을 `.onChange`로 감지해 자동 해제(iOS 16 배포 타겟이라 구버전 단일 파라미터 `onChange(of:perform:)` 사용), 닫기 버튼으로도 즉시 해제 가능
- 커밋을 빌드 가능한 최소 단위 2개로 분리(사용자 요청): (1) 컴포넌트 신설 + `project.pbxproj` 등록 + `Localizable.xcstrings` 자동 추출분(신규 안내 문구 카탈로그 항목) — `5603171`, (2) `MemoryGridView` 연동 — `f2c88ec`. 각 커밋 전 `git stash push --keep-index`로 다음 단계 변경분을 격리한 상태에서 `xcodebuild ... build` → BUILD SUCCEEDED 확인. 이번 작업과 무관한 `.claude/settings.json` 변경은 커밋에서 제외하고 그대로 둠
- 사용자가 시뮬레이터에서 직접 검증(힌트 노출, 드래그 후 자동 해제 등) 완료
- Task C(Lock 제거) 구현: `MemorySlot`/`SlotSeed`의 `isLocked`(차단 의미)를 `isReferenced`(배지 의미, 접근 차단 없음)로 재정의하고, `MemoryGridVM.handleTap`/`handleDrop`의 잠금 차단 블록을 제거해 어떤 슬롯이든 직접 가리키는 것을 항상 허용. 자기참조 포인터 차단(`handleDrop` 자기 자신 검사)과 잘못된 역참조 에러(`dereference`)는 실제 C 오류이므로 그대로 유지 — 에러 트리거 지점이 3곳에서 2곳으로 감소. `MemoryItem`의 큼직한 `lock.fill` 오버레이를 우상단 `link` 아이콘 배지(`isReferenced`일 때만 표시)로 교체. 이미 참조된 슬롯(레슨 2의 0x701C)에 직접 연결해도 연결 자체는 정상 처리하되, `codeLog`를 에러가 아닌 이중 포인터 연습 유도 안내로 대체(`handleDrop`에 `isReferenced` 분기 추가). 레슨 2 `description`/`initialCodeLog`도 "잠금 장치" 문구를 논블로킹 톤으로 수정. `LessonBlueprint`에 `hintCode: LocalizedStringResource?` 필드를 추가하고 레슨 2에 목표 코드(`int **pp = &p;`)를 채운 뒤, `MemoryGridVM.showHint()`와 그리드 툴바의 "힌트 보기" 버튼(`hintCode`가 있는 레슨에서만 노출)으로 연결
- 사용자 피드백으로 커밋 단위를 재검토: 최초 시도는 리네임+차단제거+UI+카피 변경을 한 커밋에 묶었는데, "커밋을 최소 단위로 쪼갰는지" 재확인 요청을 받아 `git reset`으로 되돌린 뒤 (1) 차단 로직 제거 (2) `isLocked`→`isReferenced` 리네임+배지 (3) 참조 슬롯 직접 연결 시 안내 메시지 (4) 레슨 2 카피 수정 (5) "힌트 보기" 버튼, 5개 커밋으로 재작성. 각 커밋 전 해당 범위만 남기고(`git checkout --`로 임시 되돌림) `xcodebuild ... build` → BUILD SUCCEEDED 확인 후 커밋
- 시뮬레이터(iPhone 16) 설치 확인: 홈 화면에서 레슨 2 카드의 새 설명 문구("이미 데이터를 가리키는 포인터가 있습니다...")가 정상 렌더링되고 크래시 없음을 스크린샷으로 확인. 그리드 화면 진입에는 좌표 기반 GUI 자동화 도구가 없어(기존 한계와 동일) 실제 인터랙션 동작은 사용자의 수동 시뮬레이터 테스트로 확인하기로 함
- 사용자가 시뮬레이터에서 직접 검증 (2026-08-05): 참조 배지 표시, 참조된 슬롯 직접 연결 시 안내 문구, 정상 클리어 경로, 힌트 보기 버튼, 기존 레슨/에러 회귀 등 테스트 항목 6개 모두 오류 없음. 다만 참조 배지(`link` 아이콘)가 너무 작아 잘 안 보인다는 피드백을 받아, 지금 당장 고치지 않고 `TODO.md` 백로그에 기록만 해둠 (크기/스타일 개선은 별도 작업) — Task C 완료로 확정
- Task D(주소 vs 값 구분) 구현: `MemoryItem.swift`에서 포인터 슬롯이 가리키는 대상 주소 표시를 `Text(target)` → `Text("→ \(target)")`로 변경해 값 슬롯(숫자만 표시)과 시각적으로 구분(커밋 `aae8bce`). `MemoryGridVM.swift`의 `handleTap` Case A(일반 포인터 codeLog)와 `handleDrop`의 대상 슬롯 자동 초기화 codeLog에 "포인터 자신도 메모리에 저장된 값(주소)"이라는 설명을 한 줄씩 추가해, 화살표 애니메이션 하나에만 의존하지 않고 상호작용마다 텍스트로도 개념을 반복 강조(커밋 `93af209`). 두 커밋 모두 커밋 전 `xcodebuild ... build` → BUILD SUCCEEDED 확인
- `Localizable.xcstrings`: 두 번째 커밋에서 CLI 빌드의 문자열 카탈로그 자동 추출이 지연되는 현상(Task 8 후속에서 발견한 것과 동일한 유형 — 컴파일러는 `.stringsdata`에 새 키를 정상 추출했으나, `xcodebuild build`를 여러 차례(증분/touch 재빌드/clean build) 반복해도 카탈로그 병합이 반영되지 않음을 확인)이 재현되어, 기존 항목과 동일한 JSON 형식으로 신규 키 2개(en/ko)를 직접 추가. `python3 -m json.tool`로 JSON 유효성 확인 후 빌드 재검증
- 사용자가 시뮬레이터에서 직접 검증 완료: 포인터 슬롯 화살표 표시, codeLog 신규 설명 문구 노출 등 정상 동작 확인 — Task D 완료로 확정
- `Localizable.xcstrings`가 Xcode 쪽에서 한 차례 더 자동 재동기화되어(사용되지 않게 된 옛 codeLog 키 정리) 별도 커밋(`e93bc47`)으로 반영

## Task 9 완료 (`feature/lesson-grid-ux-improvements`)
그리드 인터랙션 UX 개선(Task A/B/C/D) 구현 및 사용자 검증까지 모두 완료. 세부 구현 내역은 위 "Task 9 진행 상황" 참고.

- `develop`에 `--no-ff` 병합 완료 (병합 커밋 `8ac2944`), 병합 직후 `xcodebuild ... build` → BUILD SUCCEEDED 재검증
- `origin/develop`에 push 완료 (`5fca169..8ac2944`), 로컬 `feature/lesson-grid-ux-improvements` 브랜치 삭제

## 계획됨 (2026-07-30 제안, 미착수)
Task 9 Task A 리뷰 도중 사용자가 제안한 아이디어: 코드 패널(`CodeFeedbackView`)에서 쓰이는 변수명(예: `p`, `target`)을 그리드의 해당 메모리 블록 옆에도 표시하면 코드와 그리드 사이의 매핑이 더 직접적으로 보일 것이라는 제안. 지금은 구현하지 않고 `TODO.md` 백로그·`PLAN.md` 백로그에 아이디어만 기록해둠 — 착수 시점은 추후 논의.

## Task 10 진행 상황 (`feature/reference-badge-visibility`)
Task 9 병합 완료 후 사용자가 백로그 중 "레슨 2 참조 배지 가시성 개선"을 다음 착수 항목으로 선택. 배경·결정 근거는 `PLAN.md`의 "Task 10: 레슨 2 참조 배지 가시성 개선" 참고.

- `develop`에서 `feature/reference-badge-visibility` 브랜치 분기
- `TODO.md`에 Task 10 항목 등록 (백로그에 있던 항목을 Task로 승격, 관련 백로그 줄 제거)
- `MemoryItem.swift`의 참조 배지 구현 변경: `Image(systemName: "link")`를 `.caption2` + `.secondary`(회색 line 아이콘)에서 `.caption` + `.bold` + `.white` 아이콘을 `Circle().fill(Color(.main))` 배경 위에 얹는 채워진 원형 배지로 교체. 기존 트리거 조건(`slot.isReferenced`)과 배지 위치(우상단 `.topTrailing`)는 Task 9 Task C에서 확정된 그대로 유지, 시각 스타일만 조정
- `xcodebuild ... build` → BUILD SUCCEEDED 확인
- 사용자가 시뮬레이터에서 직접 검증 완료: 참조 배지 표시, 에러(빨강)/하이라이트(노랑) 배경 위 대비, 다른 슬롯 콘텐츠와 겹침 없음, 접근성 라벨, 레슨 1·3/샌드박스 회귀 없음 6개 항목 모두 정상 확인 — Task 10 완료로 확정

## Task 10 완료 (`feature/reference-badge-visibility`)
레슨 2 참조 배지 가시성 개선 구현 및 사용자 검증까지 완료. 세부 구현 내역은 위 "Task 10 진행 상황" 참고.

- `develop`에 `--no-ff` 병합 완료 (병합 커밋 `fc2d623`), 병합 직후 `xcodebuild ... build` → BUILD SUCCEEDED 재검증
- `origin/develop`에 push 완료 (`ee5c1da..fc2d623`), 로컬 `feature/reference-badge-visibility` 브랜치 삭제

## Task 11 진행 상황 (`feature/grid-variable-labels`)
Task 10 병합 완료 후 사용자가 백로그 중 "그리드 블록에 코드 패널 변수명 표시"를 다음 착수 항목으로 선택. 라벨 동작 방식을 `AskUserQuestion`으로 확정: **누적 유지**(슬롯이 코드에서 특정 변수명으로 처음 등장하면 라벨을 부여하고, 이후 다른 슬롯을 조작해도 이미 부여된 라벨은 유지) 방식 채택. 배경·결정 근거는 `PLAN.md`의 "Task 11: 그리드 블록에 코드 패널 변수명 표시" 참고.

- `develop`에서 `feature/grid-variable-labels` 브랜치 분기, `TODO.md`/`PLAN.md`에 Task 11 등록 (백로그에 있던 항목을 Task로 승격)
- `MemorySlot.swift`: `var variableName: String? = nil` 필드 추가 (커밋 `7a48e74`)
- `MemoryGridVM.swift`: `assignVariableName(_:to:)` private 헬퍼 추가 — 슬롯에 이미 이름이 있으면 덮어쓰지 않는 assign-once 방식. `handleTap`/`handleDrop`/`dereference`에서 `codeLog`를 갱신하는 각 지점마다 실제로 그 코드에 등장하는 이름(`p`/`target`/`ptr1`/`ptr2`/`value`/`unknown`/`val`)을 해당 슬롯에 매핑 (커밋 `96efc79`). 레슨 리셋 시 `setupLevel`이 슬롯 배열을 새로 생성하므로 누적된 라벨도 자연히 초기화됨
- `MemoryItem.swift`: 주소 라벨 옆에 `slot.variableName`이 있을 때만 `Color(.main)` 강조색 캡션으로 표시 (커밋 `c243b7f`)
- 매 커밋 전 `xcodebuild ... build` → BUILD SUCCEEDED 확인
- 1차 구현에 대한 사용자 시뮬레이터 검증(2026-08-11) 결과, 레슨 3(체인 연결)에서 여러 포인터 슬롯이 전부 동일하게 `p`로 표시되어 헷갈린다는 피드백을 받음. 두 가지 수정 방향(레슨별 의미 있는 변수명 선언 vs 범용 번호 매김만 적용)을 `AskUserQuestion`으로 확인해 **레슨별 의미 있는 변수명 선언**으로 확정
- `Lesson.swift`: `SlotSeed`에 `variableName: String?` 필드 추가, 레슨 3의 4개 슬롯을 `start`/`nodeA`/`nodeB`/`treasure`로 명명 (커밋 `188f464`)
- `MemoryGridVM.swift`: 기존 `assignVariableName(_:to:)`를 `resolveVariableName(for:fallback:)`으로 교체 — ①슬롯에 이미 이름이 있으면 재사용(누적 유지) ②레슨 블루프린트가 이름을 선언했다면 그 이름 사용 ③둘 다 없으면 `makePointerName()`으로 `p1`/`p2`/`p3`처럼 번호를 매겨 새로 생성. 이름을 선언하지 않은 레슨/샌드박스에서도 같은 상호작용 중 여러 포인터가 생기면 자동으로 번호가 구분되고, `codeLog` 텍스트도 항상 실제 부여된 이름을 그대로 사용하도록 통일해 코드 문구와 그리드 라벨이 어긋나던 부분(예: 레슨 1 Case A 재탭, 역참조)도 함께 해소 (커밋 `9b87535`)
- `nextPointerNameIndex` 카운터는 `setupLevel`에서 함께 초기화되어 레슨 리셋 시 `p1`부터 다시 시작함
- 2차 시뮬레이터 검증(2026-08-11)에서 두 가지 후속 문제 발견: (1) 레슨 3에서 이미 이름이 있는 슬롯(`nodeB` 등)을 연결해도 `int *nodeA = 0x702C;`처럼 숫자 주소로 표시됨 (2) 레슨 1에서 연결 직후 목적지 라벨이 상호작용 순서에 따라 `val`/`target`으로 들쭉날쭉함. 원인은 동일: `handleDrop`의 일반 연결 분기(`else`)가 소스(포인터) 이름만 부여하고 목적지 슬롯은 이름을 정하지 않은 채 주소 리터럴을 그대로 코드에 넣고 있었음
- `resolveVariableName`으로 목적지 이름도 연결 시점에 즉시 확정하고 `"int *p = 0x702C;"` 대신 `"int *p = &destName;"` 형태로 바꿔 두 문제를 함께 해결 (커밋 `1cca04d`)
- `TODO.md`에 체크리스트 항목 반영 완료
- 3차 사용자 시뮬레이터 검증(2026-08-11) 완료: 레슨 3 연결 코드가 `&nodeB` 형태로 정상 표시, 레슨 1 연결 직후 라벨 일관성, 리셋 시 `p1`부터 재시작 모두 정상 확인 — Task 11 완료로 확정

## Task 11 완료 (`feature/grid-variable-labels`)
그리드 블록에 코드 패널 변수명 표시 구현 및 3차에 걸친 사용자 시뮬레이터 검증까지 완료. 세부 구현 내역은 위 "Task 11 진행 상황" 참고. 1차 구현(누적 유지 라벨) 이후 사용자 검증 과정에서 발견된 두 가지 후속 문제(레슨 3 중복 `p` 라벨, `handleDrop` 목적지 미명명)를 각각 블루프린트 선언 이름/번호 매김, `&destName` 표기로 수정하며 반복적으로 다듬었다.

- `develop`에 `--no-ff` 병합 완료 (병합 커밋 `6a80e39`), 병합 직후 `xcodebuild ... build` → BUILD SUCCEEDED 재검증
- 병합 과정에서 `codeLog` 문자열 리터럴 변경으로 `Localizable.xcstrings`에 새 카탈로그 키가 자동 추출된 것을 확인 — 자연어(한국어 주석)를 포함한 8개 키에 `en` 번역을 채워 별도 커밋 (`a5eefc4`)
- `origin/develop`에 push 완료, 로컬 `feature/grid-variable-labels` 브랜치 삭제

## Task 12 진행 상황 (`feature/swiftui-style-cleanup`)
Task 11 병합 완료 후 사용자가 백로그 중 "SwiftUI 코드를 사용자 코딩 스타일에 맞게 정리"를 다음 착수 항목으로 선택. 정리 범위는 `AskUserQuestion`으로 **Task 1~11에서 Claude가 신설·대폭 수정한 파일 위주**로 확정(전체 25개 파일 일괄 정리는 diff·회귀 검증 부담이 커 제외), 스타일 기준은 **가이드 문서를 이 참에 함께 작성**하는 방향으로 확정.

- `develop`에서 `feature/swiftui-style-cleanup` 브랜치 분기
- 선행 조건 확인: 리포에 스타일 가이드 문서도, `.swiftlint.yml`/`.swift-format` 등 포매터 설정도 없음을 확인 — 스타일이 전적으로 저자의 암묵적 관례로만 존재했던 상태
- git tag `1.0`(`a85ba75`, 2026-02-14, 당시엔 `.swiftpm` 패키지 구조) 전체 Swift 소스를 읽어 실제 반복되는 관례를 추출
  - 들여쓰기 2 space, `import` 뒤 빈 줄 한 개
  - 타입·주요 프로퍼티에 `///` 한국어 문서 주석, 흐름 설명은 `//` 한국어
  - View 내부 선언 순서: 프로퍼티 래퍼 → 주입 `let` → `init` → `private let` 상수 → `body` → `private func` 헬퍼
  - 서브뷰는 `private extension` 안에 파라미터 없으면 **대문자 계산 프로퍼티**(`Title`/`Cards`/`ContinueButton`), 있으면 소문자 함수
  - 스택 자식 뷰 사이에 빈 줄(특히 `Spacer()` 앞뒤), 모디파이어 체인 중간에는 빈 줄 없음
  - 인자가 길면 한 줄에 하나씩 개행, 트레일링 클로저(`Button { } label: { }`) 사용
  - 모델에 종속된 enum은 타입 안에 중첩 + case별 `///`, 정적 데이터는 `static let` 배열 + `.init(...)` 축약
  - 모든 View 파일 하단에 `#Preview`
- `STYLE_GUIDE.md` 신설 — 위 관례를 11개 항목으로 문서화(로컬라이제이션 규칙은 Task 3~9에서 반복 발견한 함정(`Text(String)` 비-로컬라이즈 오버로드, `.uppercased()` 대신 `.textCase(.uppercase)`)까지 포함) (커밋 `f49c84a`)
- `TODO.md`에 Task 12 등록 (백로그 항목 승격) (커밋 `646819d`), `PLAN.md`에 Task 12 섹션(배경/진단/변경 방향/Non-goals) 추가 (커밋 `fa4202d`)
- 자동 포매터 도입은 범위에서 제외 — 대문자 계산 프로퍼티 같은 이 프로젝트 고유 관례를 표준 포매터가 존중하지 않음

### 진단 (실측 완료)
Claude가 신설한 파일들(`CCodeHighlighter.swift`, `LessonProgressStore.swift`, `AppLanguage.swift`, `GridInteractionHintOverlay.swift`, `LessonRow.swift` 등)은 2-space·한국어 `///` 주석은 지켰다. 착수 전 초벌 진단에서는 이탈 후보를 3가지로 봤으나, 전체 소스를 실측한 결과 **2가지는 이탈이 아니었고 실제 이탈은 1가지로 좁혀졌다**.

- **실제 이탈** — 뷰 본문/함수 본문의 **빈 줄이 원본보다 적어 밀도가 높음** (원본은 스택 자식마다, 특히 `Spacer()` 앞뒤로 빈 줄을 둠)
- **이탈 아님(초벌 진단 철회)** — `guard let ... else { return }` 한 줄 표기. tag `1.0` 원본도 조건 하나짜리는 한 줄이 기본형이었고(`PagingCardsScrollView.swift:125`, `MemoryGridVM.swift:166`), 줄을 나눈 경우는 조건이 여러 개이거나 길 때뿐이었다. 특히 현재 `MemoryGridVM.swift:175`의 한 줄 `guard`는 원본 `1.0`의 `:166`과 **동일한 줄**이다. 이에 맞춰 `STYLE_GUIDE.md` §7 서술도 정정 (커밋 `7ad90d5`)
- **이탈 아님(초벌 진단 철회)** — `#Preview` 누락. View 타입 전체를 스캔한 결과 누락은 `ArrowDrawLayer.swift` 하나뿐인데 tag `1.0` 원본에도 없었다(상위 뷰의 좌표 정보를 받아야만 그려지는 보조 레이어라 단독 프리뷰가 무의미). `STYLE_GUIDE.md` §10에 예외로 명시 (커밋 `7ad90d5`)

### 코드 정리 결과
대상 후보 9개 파일을 `STYLE_GUIDE.md`와 대조해 실제 이탈이 있던 5개 파일만 수정했다. 커밋은 파일·규칙 단위로 6개로 나눴고, 문자열 리터럴은 한 곳도 건드리지 않아 `Localizable.xcstrings` 키에는 영향이 없다.

- `App/AppLanguage.swift`: `private static let` 키 2개가 `displayName`과 메서드 사이에 끼어 있던 것을 case 선언 바로 아래로 이동 (커밋 `cdf0c29`)
- `Scene/Quest/Entity/GridInteractionHintOverlay.swift`: 단일 표현식 계산 프로퍼티 2곳의 명시적 `return` 제거(tag `1.0`의 `Image+.swift`/`ShakeEffect`가 쓰는 암시적 반환과 통일), `HandIcon` 설명 주석을 `//` → `///`로 변경 (커밋 `aedfea5`)
- `Scene/Main/MainView.swift`: `chapterColorPalette` 배열의 끝 쉼표 제거, 100자를 넘던 `lessonRow` 호출을 인자별 개행 (커밋 `c2f1cfb`)
- `Core/Lesson.swift`: 옵셔널 프로퍼티의 불필요한 `= nil` 4곳과 `Bool` 타입 표기 2곳 제거(`1.0`의 `MemorySlot` 표기와 통일), 챕터 2~5의 `.init` 한 줄 선언(최대 107자)을 인자별 개행 (커밋 `f049201`, `0af91d0`)
- `Scene/Quest/MemoryGridVM.swift`: `nextPointerNameIndex`가 `showHint`와 `resolveVariableName` 사이에 선언돼 있던 것을 `@Published` 프로퍼티 아래·`init` 앞으로 이동 (커밋 `0f2d33a`)
- 무수정 4개 파일: `Core/LessonProgressStore.swift`, `DesignSystem/Component/CCodeHighlighter.swift`, `Scene/Quest/Entity/MemoryItem.swift`, `Scene/Quest/Entity/ArrowDrawLayer.swift` — 대조 결과 이탈 없음. 특히 `MemoryItem`은 Task 9~11에서 추가된 변수명 라벨 `HStack`·참조 배지 오버레이가 이미 원본 여백 관례를 따르고 있었다
- 앞 3개 커밋(`cdf0c29`, `74aa686` 이전까지)은 커밋 전 `xcodebuild ... build` → BUILD SUCCEEDED 확인. 이후 4개 커밋(`c2f1cfb`, `f049201`, `0af91d0`, `0f2d33a`)은 사용자가 빌드·시뮬레이터 검증을 직접 수행하기로 해 CLI 빌드를 생략했고, 사용자 검증 완료로 확정

### 작업 중 되돌린 변경과 가이드 정정
정리를 진행하며 `STYLE_GUIDE.md` 자체가 원본과 어긋난 규칙 4건을 담고 있던 것이 드러나, 코드를 고치는 대신 가이드를 고쳤다. 가이드를 tag `1.0`에서 추출할 때 일부 규칙을 실측 없이 일반적인 Swift 관례로 적어버린 것이 원인이다.

- guard 줄바꿈: "조건이 길면 `else`를 내린다"고 적었으나 원본도 조건 하나짜리는 한 줄이 기본형이었고, 현재 `MemoryGridVM.swift:175`의 한 줄 `guard`는 원본 `1.0`의 `:166`과 동일한 줄이었다 → §7 정정 (커밋 `7ad90d5`)
- `#Preview`: "모든 View 파일에 둔다"고 적었으나 누락은 `ArrowDrawLayer` 하나뿐이고 원본에도 없었다(상위 뷰 좌표를 받아야 그려지는 보조 레이어) → §10에 예외 명시 (커밋 `7ad90d5`)
- 줄 끝 공백: "남기지 않는다"고 적었으나 원본은 빈 줄에 들여쓰기 공백이 남는 Xcode 기본 동작을 그대로 따르고 있었다(`MainView.swift` 기준 공백만 10줄 / 완전 빈 줄 3줄) → 일부러 넣지도 일괄로 지우지도 않는 방침으로 §1 정정 (커밋 `be9a073`)
- View 프로퍼티 선언 순서: "프로퍼티 래퍼 → 주입 `let`"으로 적었으나 원본 `MemoryItem`은 `let slot` 다음에 `@ObservedObject var vm`을 두는 반대 순서였다. 이 잘못된 규칙에 맞춰 `LessonRow`의 `@ObservedObject`를 위로 올리는 커밋을 만들었다가, 원본에서 오히려 멀어지는 변경임을 확인하고 `git reset`으로 되돌린 뒤 가이드 §3을 정정 (커밋 `74aa686`)

## Task 12 완료 (`feature/swiftui-style-cleanup`)
SwiftUI 코드 스타일 정리 및 사용자 빌드·시뮬레이터 검증까지 완료. 세부 구현 내역은 위 "Task 12 진행 상황" 참고. 이번 Task의 산출물은 코드 변경보다 `STYLE_GUIDE.md`(이후 모든 SwiftUI 작업의 기준 문서)와, 가이드를 실측으로 검증하며 잡아낸 규칙 오류 4건의 정정이다.

- 브랜치 커밋 18개(코드 6 + 문서 12), `develop`에 `--no-ff` 병합 완료 (병합 커밋 `efe3119`)
- 빌드·시뮬레이터 회귀 검증은 사용자가 직접 수행 완료 후 병합
- `origin/develop`에 push 완료 (`ba6a327..efe3119`), 로컬 `feature/swiftui-style-cleanup` 브랜치 삭제

## 로드맵 정리 (2026-08-14)
Task 12 병합 완료 후 사용자와 남은 항목의 순서를 정리했다. 세부 내용은 `PLAN.md`의 "출시 로드맵", "백로그 A", "백로그 B" 참고.

- **Chapter 2~5 콘텐츠 저작을 1.0 이후 업데이트로 확정** — 분량이 가장 크고, Chapter 1(레슨 3개) + 플레이그라운드만으로 학습 루프가 완결되므로 출시를 막을 이유가 없다는 판단. 남은 백로그 중 가장 마지막 순서
- **언어 변경 방식 개선 항목 신설** — 현재 `AppLanguage.apply(_:)`가 `UserDefaults`의 `AppleLanguages`를 직접 덮어쓰고 "재시작 필요" 알럿을 띄우는 비공식 우회 방식이다. 이를 iOS 앱별 언어 설정(Settings > 앱 > 선호하는 언어)으로 위임하고, 앱 안에서는 현재 언어만 표시 + 설정 앱 딥링크로 바꾼다. 시스템이 언어 변경 시 앱을 종료시키므로 복귀 시 자동으로 새 언어가 적용된다
  - 구현 전 확인 필요: 설정 앱에 앱별 언어 항목이 실제로 노출되는지(로컬라이제이션 2개 이상 조건은 충족), Task 3의 "최초 실행 시 한국어 강제" 로직이 시스템 설정과 같은 저장소를 공유해 충돌하지 않는지
- **학습 효과 보강 항목 신설, 1.0 범위 확정** — "포인터 개념을 모르는 사용자에게 실제로 학습 효과가 있을까, 이론 설명 화면을 따로 만들어야 할까"라는 사용자 우려에서 출발. 코드 대조 결과 `OnboardingView`는 조작법만 설명하고 개념 설명이 앱 어디에도 없으며, 레슨 1의 설명("값이 아니라 '주소'가 중요합니다")이 이미 개념을 아는 사람에게만 통하고, 레슨 1~3의 성공 조건이 모두 공간적 연결(`anyPointerPointsTo`/`chain`)이라 개념 이해 없이도 클리어 가능하다는 점을 확인
  - 후보안 6개를 `PLAN.md` "백로그 B"에 우선순위와 함께 기록하고, 별도 이론 화면보다 레슨 흐름 안에 개념 설명을 녹이는 방향을 권장안으로 제시
  - 사용자가 **B-2(레슨 0 "변수와 메모리") → B-1(레슨별 개념 카드) → B-4(레슨 마무리 요약)** 를 1.0 범위로 확정. 별도 이론 화면은 만들지 않는다
  - B-3(예측→확인), B-5(용어집), B-6(오개념 피드백)은 1.x로 이관. 특히 B-3는 효과가 가장 크지만 성공 조건·인터랙션 모델 자체를 건드려야 해 Chapter 2~5 콘텐츠 저작과 함께 다루는 편이 낫다는 판단
  - 각 항목은 실제 착수 시점에 별도 Task로 승격하고, 그때 세부 실행 계획을 확정한다

## 1.0 착수 순서 확정 (2026-08-14)
사용자가 "학습 효과 보강을 시작하기 전에 브랜딩을 먼저 정리해야 나중에 디자인을 다시 고치지 않는 것 아닌가"라고 제기해, 1.0 항목의 착수 순서를 **언어 → 브랜딩 → 학습 효과 보강 → 심사 준비**로 확정했다.

- 판단 근거를 위해 색상 사용 현황을 실측: SwiftUI 하드코딩 색상(`Color.red` 등) **0건**, 전부 자산 참조(`Color(.main)` 등)로 통일돼 있고 색상 자산은 10개(`Main`이 13회로 최다 참조). 앱 이름 노출도 `MainView`의 `Text` 두 줄뿐
- 따라서 **팔레트 교체·이름 변경의 코드 비용은 지금이나 나중이나 거의 동일**하다 — 브랜딩을 먼저 두는 실익은 색이 아니라 **도식 표기 규칙**에 있다는 결론. B-2/B-1이 만들 개념 도식은 비주얼 언어가 바뀌면 통째로 다시 만들어야 하는 유일한 산출물이다
- 이에 기존 백로그의 "앱 이름/브랜딩/아이콘 재검토"를 **"브랜딩·비주얼 언어 확정"(`PLAN.md` 백로그 C)** 으로 재정의하고, 범위에 도식 표기 규칙(값 vs 포인터 구분, 화살표 표기, 색이 상태를 의미하는지 종류를 의미하는지)을 추가
- 색상 자산 이름이 `Red`/`Green`처럼 색 자체를 가리켜 의미가 바뀌면 어긋나는 문제도 백로그 C에서 함께 판단하기로 기록
- 언어 작업을 1순위로 둔 이유는 `SettingView` 한 파일로 끝나는 완전 독립 항목이기 때문
- 함께 제기된 "다른 교재·앱은 CS 개념을 어떻게 설명하는가, 책은 결국 일러스트뿐인데"라는 질문에 대해 조사 결과를 `PLAN.md` 백로그 B의 "참고 사례와 설계 원칙" 절에 정리 — 책의 일러스트는 매체의 한계지 이상적 방법이 아니므로 흉내 낼 필요가 없고, 가져올 것은 표기 규칙의 일관성과 구체→추상 순서라는 결론. notional machine 개념, 선행 사례 4건(Python Tutor / Pointer Fun with Binky / Execute Program / Brilliant), 포인터의 알려진 오개념 3가지를 B-2/B-1 설계 기준으로 기록

## 문서 정합성 점검 (2026-08-14)
- 이 문서 맨 위 "현재 상태" 섹션이 Task 5 시점(다음은 Task 6 착수 예정)에 멈춰 있던 것을 발견 — Task 6 이후로는 Task별 섹션만 아래에 추가되고 요약이 갱신되지 않았다. Task 1~12 병합 완료 상태로 갱신하고, 기존 내용은 "Task 1~2 완료 및 초기 검증" 섹션으로 분리해 보존
- 그 외 Task 1~12의 TODO/PLAN/PROGRESS 기록은 실제 커밋 이력과 일치함을 확인

## Task 13 진행 상황 (`feature/app-language-settings-link`)
1.0 착수 순서 1번 "언어 변경 방식 개선"을 백로그에서 Task로 승격해 착수. 배경·변경 방향은 `PLAN.md`의 "백로그 A" 참고.

- 착수 전 확인 사항 판단: `AppLanguage.applyInitialLanguageIfNeeded()`의 `AppleLanguages` 쓰기가 iOS 앱별 언어 설정과 **같은 저장소**를 공유함을 확인. `hasSetInitialLanguage` 플래그로 1회만 실행되므로 시스템 선택을 되덮어쓰지는 않지만, 이번 작업 목적(비공식 직접 쓰기 제거)과 어긋나는 코드가 남는다고 판단해 `AskUserQuestion`으로 **강제 로직 제거** 확정. `ko`/`en` 외 언어 기기는 `developmentRegion`(`ko`) 폴백으로 한국어가 되어 "기본 한국어" 의도도 대부분 유지된다
- `SettingView.swift`: 언어 Section의 `ForEach(AppLanguage.allCases)` 선택 목록과 "재시작 필요" 알럿, `selectLanguage(_:)`/`selectedLanguage`/`isRestartAlertPresented` 상태를 모두 제거. 현재 언어를 표시하는 행 하나(`LanguageRow`)로 교체하고 탭 시 `UIApplication.openSettingsURLString`으로 설정 앱 이동, Section footer로 "설정에서 언어를 바꾸면 앱이 다시 시작됩니다." 안내 (커밋 `ade7318`). `STYLE_GUIDE.md` §3/§4에 맞춰 `openAppSettings()`는 `body` 아래 `private func`로, `LanguageRow`는 `private extension`의 대문자 계산 프로퍼티로 배치
- `MyApp.swift`: `init()`의 `AppLanguage.applyInitialLanguageIfNeeded()` 호출 제거, 본문이 비어 `init` 자체를 삭제 (커밋 `de33dc2`)
- `AppLanguage.swift`: `apply(_:)`/`applyInitialLanguageIfNeeded()`와 `appleLanguagesKey`/`hasSetInitialLanguageKey` 상수를 제거해 `UserDefaults` 의존을 완전히 끊고, `current`를 `Bundle.main.preferredLocalizations.first` 기준으로 변경. 선택 목록이 없어져 불필요해진 `CaseIterable`/`Identifiable`/`id`도 제거 (커밋 `aa8a712`)
- `Localizable.xcstrings`: 이번에는 CLI 빌드의 자동 추출이 정상 동작해 신규 문구 2개("표시 언어", 설정 이동 안내)가 빈 항목으로 생성되고 제거된 알럿 문구 2개가 `extractionState: "stale"`로 표시된 것을 확인. 신규 항목에 `en` 번역을 채우고 stale 항목 2개는 삭제, `python3 -m json.tool`로 JSON 유효성 확인 (커밋 `7894242`)
- 매 커밋 전 `xcodebuild -scheme PointerQuest -destination 'generic/platform=iOS Simulator' build` → BUILD SUCCEEDED 확인. 커밋은 빌드 가능한 최소 단위 5개(문서 1 + 코드 3 + 카탈로그 1)로 분리했고, `SettingView` → `MyApp` → `AppLanguage` 순서로 진행해 중간 커밋에서도 참조가 깨지지 않도록 함
- 기존 사용자 기기에 남아 있는 `hasSetInitialLanguage`/`AppleLanguages` 값은 앱이 더 이상 읽지 않으므로 무해하다 (별도 마이그레이션 없음)
- 1차 사용자 시뮬레이터 검증(2026-09-02): 설정 화면의 언어 행을 탭하면 설정 앱의 Pointer Quest 페이지로 이동하는 것까지는 정상이나, **그 페이지에 "언어" 항목이 나타나지 않는 문제** 발견
  - 원인 조사: 빌드된 `.app` 번들을 확인한 결과 `en.lproj`/`ko.lproj`가 각각 `Localizable.strings`를 담고 있고 `CFBundleDevelopmentRegion`도 `ko`로, PLAN에서 확인 항목으로 적어둔 "2개 이상 로컬라이제이션" 조건은 이미 충족돼 있었다. 즉 앱 번들 문제가 아니었다
  - 실제 조건은 기기 쪽에 있었다 — iOS는 **기기의 선호하는 언어(설정 > 일반 > 언어 및 지역)가 2개 이상일 때만** 앱별 언어 항목을 노출한다. 언어가 하나뿐인 기본 시뮬레이터에서는 항목 자체가 숨겨진다
  - `Info.plist`에 `UIPrefersShowingLanguageSettings = YES`를 추가해 기기 언어 개수와 무관하게 항상 노출되도록 수정, `project.yml`에도 동일하게 반영. `plutil -lint` 통과 및 빌드된 번들의 `Info.plist`에 키가 실제로 포함됐는지 확인 (커밋 `a0e967f`)
  - 이 키가 없으면 언어가 하나인 기기에서 설정 화면의 언어 행이 막다른 길이 된다 — 앱 내 선택 UI를 없앤 이번 설계에서는 필수 조건이다
- 2차 검증(2026-09-02): 앱 삭제 후 재설치하니 설정 앱의 Pointer Quest 페이지에 "언어" 항목이 정상 노출됨 — `UIPrefersShowingLanguageSettings` 수정이 유효함을 확인
- 3차 검증에서 남은 증상 하나: 시뮬레이터(iPhone 17, iOS 26.5)에서 앱 내 "표시 언어" 행을 탭하면 설정 앱이 **최상단만 열리고 Pointer Quest 페이지까지 들어가지 못함**
  - 설정 앱 프로세스가 떠 있지도 않은 상태(`simctl terminate` → no such process)에서 콜드 스타트로도 재현돼, 설정 앱의 화면 상태 캐시 문제는 아님을 확인
  - `UIApplication.openSettingsURLString`은 앱 설정 페이지로 가는 유일한 공식 API이고(`App-prefs:` 계열 비공식 URL은 iOS 18에서 대부분 차단됨) 코드 쪽에 바꿀 여지가 없어, 원인을 시뮬레이터 한계와 iOS 18+ 설정 앱 재편 두 가지로 좁힌 뒤 **실기기 확인을 판별법으로 제시**
  - **사용자가 실기기에서 앱 언어 변경이 정상 동작함을 확인 완료** — 시뮬레이터 한계로 확정, 코드 변경 없이 마무리. 검토했던 보완안(footer에 설정 경로 명시, 경로 안내 알럿)은 채택하지 않음

## Task 13 완료 (`feature/app-language-settings-link`)
언어 변경 방식 개선 구현 및 실기기 검증까지 완료. 세부 구현 내역은 위 "Task 13 진행 상황" 참고. 앱에서 `AppleLanguages`를 직접 읽고 쓰던 코드가 완전히 사라졌고(grep 0건), 언어 변경은 iOS 앱별 언어 설정에 위임된다.

- 검증 과정에서 발견한 핵심 사항: 앱별 언어 항목은 앱이 2개 이상 로컬라이제이션을 갖는 것만으로는 부족하고 **기기의 선호하는 언어가 2개 이상이어야** 노출된다. 앱 내 선택 UI를 없앤 이번 설계에서는 `UIPrefersShowingLanguageSettings`가 필수 조건이다
- 시뮬레이터에서는 설정 앱 딥링크가 앱 페이지까지 도달하지 못하므로, 이후 이 동선을 다룰 때는 실기기로 검증해야 한다
- 브랜치 커밋 9개(코드 4 + 문서 5), `develop`에 `--no-ff` 병합 완료 (병합 커밋 `03933a9`), 병합 직후 `xcodebuild ... build` → BUILD SUCCEEDED 재검증
- `origin/develop`에 push 완료 (`1e0229c..03933a9`) — 2026-08-14 로드맵 정리 문서 커밋 6개도 이때 함께 푸시됨. 로컬 `feature/app-language-settings-link` 브랜치 삭제

## 리포 정리 (2026-09-02)
Task 13 병합 후 작업 트리에 남아 있던 변경을 정리했다. 앱 동작에는 영향이 없고, 매번 작업 트리가 더러워지는 것을 막기 위한 정리다.

- Xcode가 `project.pbxproj`의 `PBXBuildFile` 항목을 알파벳순으로 재정렬한 변경(9줄 이동, 내용 동일)을 커밋 — Task 1~11에서 파일 참조를 수동 추가하며 순서가 어긋나 있던 것을 Xcode가 정규화한 결과다 (커밋 `774b7e1`)
- 그 과정에서 `git add`가 거부되는 문제를 발견: `.gitignore`의 `### SwiftPM ###` 섹션에 `.swiftpm` 패키지 시절 잔재인 `*.xcodeproj`가 남아 프로젝트 디렉터리 전체를 무시하고 있었고, 이것이 `project.pbxproj`만 추적하려고 둔 Xcode Patch 섹션의 예외 규칙(`!*.xcodeproj/project.pbxproj`)을 무력화하고 있었다. 해당 줄을 제거해 `git add -f` 없이 커밋할 수 있게 함 (커밋 `21d25a4`). `xcuserdata` 등 나머지 무시 규칙은 그대로 동작함을 확인
- `.claude/settings.json`(팀 공유용 권한 허용 목록)을 추적 시작 — `.gitignore`가 개인 설정 `settings.local.json`만 무시하도록 이미 지정돼 있었으나 정작 공유 파일이 커밋되지 않은 상태였다 (커밋 `d262958`). Task 9 당시 "작업과 무관해 커밋에서 제외"했던 항목을 여기서 마무리
- 정리 후 재빌드해 작업 트리가 깨끗하게 유지됨을 확인, `origin/develop` 푸시 완료 (`03933a9..d262958`)

## Task 14 진행 상황 (`feature/branding-visual-language`)
1.0 착수 순서 2번 "브랜딩·비주얼 언어 확정"을 백로그 C에서 Task로 승격해 착수. 배경은 `PLAN.md`의 "백로그 C" 참고.

- 착수 시점 사용자 결정 3건으로 범위를 **도식 표기 규칙 문서화 + 색 의미 정리**로 좁힘 — (1) 앱 이름/부제는 `Pointer Quest` / `메모리의 미로` 현행 유지, (2) 색 자산은 이름 유지하고 의미만 정의, (3) 문서는 `VISUAL_LANGUAGE.md`로 신설. 세 결정 모두 `PLAN.md` 백로그 C의 "확정된 방향"에 기록
- 규칙을 새로 발명하지 않고 **이미 화면에 구현된 표기를 실측해 승격**하는 방식으로 작성했다. `MemoryItem.swift`(슬롯 3종 표기·배지·테두리), `ArrowDrawLayer.swift`(선/머리/애니메이션 수치), `MemorySlot.swift`(종류·상태 필드), `MainView.swift`/`LessonRow.swift`(챕터 그라데이션), `CCodeHighlighter.swift`(코드 패널 팔레트)를 읽고 실제 값을 그대로 문서화
- **핵심 결정 — 색의 두 축 분리**: 모든 시각 요소가 종류(값/포인터/빈칸)와 상태(에러/강조/참조) 중 정확히 하나에 속하고, **테두리 색 = 종류 / 배경 색 = 상태**로 서로 다른 시각 채널을 쓴다. 이 규칙은 이미 코드에 대부분 구현돼 있었고 명문화되지 않았을 뿐이다 — 백로그 C가 "색이 상태를 의미하는지 종류를 의미하는지 정리가 필요"라고 적은 항목의 답이 된다
- 코드 패널(`CodeFeedbackView`/`CCodeHighlighter`)의 초록·주황은 **에디터 팔레트라는 제3의 축**으로 명시적으로 분리했다. 학습자가 다른 도구에서 이미 학습한 관례라 그리드 규칙을 덮어씌우면 오히려 낯설어진다는 판단
- 색 자산 값을 실측해 대응표 작성 — `Main` `#007FFF`(12회), `Green` `#41D941`(2회), `Red` `#F45B69`(3회), `Yellow` `#FEE449`(2회), Light 계열 4개는 그라데이션 짝(각 1~2회), `LightBlown`/`Text1`은 **참조 0건**
- 접근성 항목 추가 — 색각 이상 사용자를 위해 색은 보조 채널로만 쓴다는 규칙과, 현재 이미 충족돼 있음을 확인(폰트 구분, `→` 접두어, 흔들림 모션, `link` 심볼 형태, `accessibilityLabel`)
- 백로그 B(B-2/B-1) 착수 시 쓸 **새 도식 체크리스트 6항목**을 문서 말미에 배치

### 실측 중 발견한 이탈 6건 (수정하지 않고 목록화)
백로그 C의 Non-goal("규칙을 문서화하고 어긋나는 곳을 목록으로만 남긴다")에 따라 수정은 별도 Task로 미뤘다. `VISUAL_LANGUAGE.md` §7과 `TODO.md` Task 14에 동일 목록 유지.

- `MemoryItem.swift:74` — `isError`일 때 테두리가 `Red`로 덮여 **에러인 동안 값/포인터 구분이 사라진다.** 축 분리를 어기는 유일한 지점이며, 에러는 배경 30%와 흔들림으로 이미 전달되므로 테두리는 종류를 유지하는 것이 맞다
- `MainView.swift:5-7` — 챕터 그라데이션이 상태·종류 색(`Green`/`Red`)을 장식으로 재사용. 화면이 분리돼 당장 오해를 부르진 않지만 축 규칙상 이탈
- `LessonRow.swift:40` — 완료 체크마크가 자산이 아닌 시스템 `.green` 하드코딩
- 색 자산 10개 중 9개가 **다크 모드 대응 없음**(light appearance만). 상태 배경 30%의 다크 대비 미확인. 다크 변형을 가진 유일한 자산 `Text1`은 미사용
- 미사용 자산 2개(`LightBlown`/`Text1`)
- **PLAN.md의 2026-08-14 실측 "하드코딩 색상 0건" 정정** — 그 이후 Task 9에서 추가된 파일들이 `.green`/`.orange`/`.white`/`Color(white: 0.15)`/`.gray`를 직접 쓴다. 코드 패널 것은 의도된 예외로 규정했고, `LessonRow`의 `.green`만 실제 이탈

## Task 14 완료 (`feature/branding-visual-language`)
브랜딩·비주얼 언어 확정 완료. 세부 내역은 위 "Task 14 진행 상황" 참고. 백로그 B(B-2/B-1)가 도식을 만들 때 참조할 표기 규칙이 `VISUAL_LANGUAGE.md` 하나로 고정됐다.

- 이번 Task는 **문서만 변경**되어 코드 변경이 0건이다. 따라서 빌드·시뮬레이터 검증 대상이 없었다
- 커밋 5개 — 포매팅 1(`6d33122`) + 문서 4(`c533c12` PLAN / `3ae0e5b` VISUAL_LANGUAGE 신설 / `77b75e2` TODO / `0e66f62` PROGRESS). `develop`에 `--no-ff` 병합(병합 커밋 `ee55329`) 후 `origin/develop` 푸시(`126a86f..ee55329`), 로컬 브랜치 삭제 완료
- 작업 중 발견해 함께 처리한 것 — `CLAUDE.md`의 마크다운 규칙("헤더 뒤에 빈 행을 두지 않는다")이 기존 문서 4개에 적용돼 있지 않았다. PLAN 52곳·PROGRESS 33곳·TODO 17곳·STYLE_GUIDE 12곳을 정리했고, **포매팅만 담은 커밋을 먼저 쌓고 그 위에 내용 커밋을 얹어** 내용 diff에 공백 변경이 섞이지 않게 했다(`git diff --ignore-blank-lines` 결과 0으로 확인). `PROPOSAL.md`는 SSC 제출 시점의 기록 문서라 제외
- 1.0 출시 전 항목 4개 중 2개(1. 언어 변경 방식 개선 / 2. 브랜딩·비주얼 언어 확정) 완료

## Task 15 진행 상황 (`feature/lesson-zero-variables`)
1.0 착수 순서 3번 "학습 효과 보강"의 첫 항목인 **B-2 레슨 0 "변수와 메모리"** 를 Task로 승격해 착수(2026-09-03). 배경은 `PLAN.md`의 "백로그 B" 참고.

### 착수 전 확인 사항 3건의 결론
- **레슨 id 0 점유 → 샌드박스를 100으로 이동.** 착수 시 재실측한 결과 `UserDefaults` 충돌은 **없었다** — 샌드박스의 성공 조건은 `.sandbox`이고 `checkSuccess`가 이 케이스에서 `break`하므로 `finishLevel()`이 호출된 적이 없어, `completedLessonIds`에 `0`이 저장될 수 있는 경로 자체가 없다. 기존 사용자의 저장값은 `{1, 2, 3}` 범위뿐이다
- 진짜 제약은 저장소가 아니라 **내비게이션**이었다. `Lesson`은 `id` 기준 `Hashable`(`Lesson.swift`의 수동 `==`/`hash`)이고 `MainView`가 `navigationDestination(for: Lesson.self)`로 값 기반 내비게이션을 쓰므로, 같은 id를 가진 두 `Lesson`이 공존하면 안 된다. 이 이유를 `sandboxLesson` 선언 위 주석으로 남겨 다음에 id를 건드리는 사람이 다시 실측하지 않게 했다
- **성공 조건 → `.inspectedAll(indices:)` 신설.** 기존 3케이스는 모두 포인터 연결을 전제해 레슨 0에 쓸 수 없었다. `.sandbox` 재사용안은 클리어 판정이 없어 레슨 0만 영구히 체크마크가 붙지 않으므로 배제했다

### 구현
- `MemoryGridVM`에 `inspectedIndices: Set<Int>` 추가. 값 슬롯 탭 시 `recordInspection(of:)`이 (1) 성공 조건이 `.inspectedAll`이고 (2) 해당 슬롯이 확인 대상일 때만 동작하고, 아니면 `false`를 반환해 기존 코드 로그가 그대로 쓰이게 했다 — 레슨 1~3의 탭 동작에 영향이 없다
- 코드 패널 문구는 `int age = 20; // 이름 age, 주소 0x7004, 값 20` + `// 아직 열어보지 않은 상자가 N개 남았어요.` 두 줄이다. **주소·이름·값 세 가지를 한 화면에서 나란히 보여주는 것**이 이 레슨의 전부이며, `VISUAL_LANGUAGE.md` §2가 "메모리의 모든 칸에는 번호가 있다"를 레슨 0의 첫 개념으로 지목한 것과 같은 내용이다
- **재탭 시 완료 알럿 재노출을 막았다** — `inspectedIndices.insert(index).inserted`가 `true`일 때(처음 확인)만 `checkSuccess()`를 호출한다. 이 가드가 없으면 알럿을 닫은 뒤 같은 칸을 다시 눌렀을 때 알럿이 다시 뜬다
- 레슨 0 데이터는 값 슬롯 3개(`age` 20 / `score` 100 / `level` 7)뿐이고 포인터·화살표·힌트 코드가 없다. `SlotSeed.variableName`(Task 11)으로 이름을 직접 선언해 그리드 라벨과 코드 패널 문구가 처음부터 일치한다
- 도식 체크리스트(`VISUAL_LANGUAGE.md` §8) 통과 — 값 슬롯 표기를 그대로 사용, 관계를 그리지 않으므로 화살표 없음, 새 색 추가 없음, 흑백에서도 폰트·라벨로 구분됨, 변수명 일치, 포인터 칸이 없어 `→` 규칙 해당 없음

### 검증
- 4개 단위(샌드박스 id 이동 / 성공 조건 케이스 / VM 관찰 경로 / 레슨 데이터)마다 `xcodebuild ... build` 실행, 전부 **BUILD SUCCEEDED**
- 로컬라이제이션은 두 방향을 대조해 확인했다 — 빌드 산출물의 `*.stringsdata`(소스가 실제로 방출한 키 5개)와 `PointerQuest.app/en.lproj/Localizable.strings`(카탈로그가 컴파일한 키)가 **5개 모두 문자 단위로 일치**. 키가 어긋나면 영어에서만 조용히 한국어로 폴백되므로 눈으로는 잡히지 않는 종류의 오류다
- 시뮬레이터는 최초 실행 Welcome 시트까지만 확인했다. 그 이상은 탭이 필요해 **사용자 검증으로 남겼고**, 아래에서 통과했다

### 사용자 검증 결과 (2026-09-03)
- 레슨 0 행 노출, 상자 3개 탭 시 코드 패널 문구와 남은 개수, 3개 모두 확인 시 완료 알럿·체크마크까지 **정상 확인**
- 사용자가 "리셋을 누르면 완료 팝업이 다시 뜨는 것이 맞는가"를 제기 — **정상 동작으로 확정.** 정적 추적만으로는 `isSuccess = true`를 쓰는 경로가 `finishLevel()` 하나뿐이라 리셋 경로로 설명되지 않아, 추측으로 고치는 대신 **임시 `print` + `simctl launch --console-pty`로 로그를 받아** 판별했다
  - 로그: 리셋 시점은 `isSuccess: false -> false`이고 직후 `finishLevel()`이 찍히지 않는다. 그 뒤 세 번의 탭(`0x7004`/`0x7018`/`0x7028`)이 찍히고 나서야 `finishLevel()`이 호출된다 — 즉 팝업은 리셋이 아니라 **리셋 후 재확인**으로 뜬 것이다
  - 레슨 1~3도 리셋 후 포인터를 다시 연결하면 완료 알럿이 다시 뜬다. 레슨 0만 억제하면 오히려 일관성이 깨지므로 코드를 바꾸지 않았다
  - 진단 `print` 2개는 제거하고 재빌드해 잔여 0건·BUILD SUCCEEDED 확인
  - 교훈: 증상 보고가 "리셋을 누르면"이었지만 실제 트리거는 "리셋 후 재확인"이었다. **코드 경로로 설명되지 않는 증상은 고치기 전에 로그로 트리거를 먼저 확정한다** — 여기서 추측으로 `finishLevel`에 1회 제한 플래그를 넣었다면 없는 버그를 위해 정상 동작(재클리어)을 막는 코드가 남았을 것이다

## Task 15 완료 (`feature/lesson-zero-variables`)
B-2 레슨 0 "변수와 메모리" 구현·검증·병합 완료. 세부 내역은 위 "Task 15 진행 상황" 참고. 레슨 1이 전제하던 "변수 = 이름표 붙은 상자 / 주소 = 상자 번호"가 이제 앱 안에서 먼저 채워진다.

- 커밋 5개 — `f58ad9d` 샌드박스 id 이동 / `743530d` 성공 조건 `.inspectedAll` + VM 관찰 경로 / `2306ad2` 레슨 0 데이터 / `d9ec7b8` 로컬라이제이션 / `6cec4aa` 문서. `Lesson.swift` 한 파일의 변경을 **hunk 단위로 3개 커밋에 나눠** 담아, 각 커밋이 하나의 논리 단위이자 빌드 가능한 상태가 되도록 했다(`git apply --cached`로 hunk 분리)
- `develop`에 `--no-ff` 병합(병합 커밋 `8ca55c9`), 병합 직후 `xcodebuild ... build` → BUILD SUCCEEDED 재검증, `origin/develop` 푸시(`842bd00..8ca55c9`), 로컬 브랜치 삭제 완료
- **코드 변경은 3개 파일뿐이다** — `Lesson.swift`(+24), `MemoryGridVM.swift`(+40), `Localizable.xcstrings`(+80). 새 View 파일이 0건이라 `project.pbxproj`를 건드릴 일도 없었다. Task 11의 `SlotSeed.variableName`과 `VISUAL_LANGUAGE.md` §2의 값 슬롯 표기가 이미 있어 도식·라벨을 새로 만들지 않은 결과다
- 1.0 출시 전 항목 3번(학습 효과 보강)의 3개 중 **B-2 완료**, B-1·B-4가 남았다

## Task 16 진행 상황 (`feature/lesson-concept-cards`)
1.0 착수 순서 3번 "학습 효과 보강"의 두 번째 항목인 **B-1 레슨별 개념 카드**를 Task로 승격해 착수(2026-09-06). 배경은 `PLAN.md`의 "백로그 B" 참고.

### 착수 전 확인 사항 4건의 결정
2026-09-03에 실측해 둔 4건을 착수 시점에 사용자 결정으로 확정했다. 결정문은 `TODO.md` Task 16 절에도 같은 내용으로 남겼다.

- **내용 위치 → `Lesson.conceptCard`.** `LessonBlueprint`는 배치·판정의 축이고 개념 카드는 설명이라 축이 다르다
- **도식 → 기존 뷰 재사용.** 새 PNG를 그리지 않는다. 착수 후 실측에서 이 결정의 비용이 예상보다 작다는 것이 확인됐다(아래)
- **노출 → 레슨 최초 진입 시 자동 시트 + 툴바 `(i)`로 재열람.** 재진입 시에는 자동으로 뜨지 않아 반복 플레이를 막지 않는다
- **툴바·레슨 0 → `(i)` 추가, 레슨 0은 카드 없음.** `conceptCard`를 옵셔널로 두면 레슨 0 제외가 데이터 한 곳으로 표현되고 뷰에는 조건문이 늘지 않는다

### 착수 후 실측에서 바뀐 것
- **`MemoryItem` 분리 비용이 예상보다 작았다.** TODO에는 "`.draggable`/`.dropDestination`이 붙어 있어 도식에서도 드래그가 된다"고만 적혀 있었으나, 실제로는 탭·더블탭 제스처가 `MemoryItem`이 아니라 `MemoryGridView`(`:36-44`)에 붙어 있어 떼어낼 상호작용이 두 개뿐이었다. `vm`을 쓰는 곳도 `.dropDestination` 클로저 한 곳이다
- **화살표 추출이 계획에 없던 단위로 추가됐다.** 도식에도 화살표가 필요한데 `ArrowDrawLayer`는 `vm`에 묶여 있어 그대로 쓸 수 없다. 선/머리 수치(`VISUAL_LANGUAGE.md` §3)를 카드가 복사해 갖게 두는 대신 `PointerArrow`로 뽑아 양쪽이 같은 표기를 공유하게 했다
- **열람 기록에 새 저장소가 필요 없다.** `LessonProgressStore`가 이미 `Set<Int>`를 `UserDefaults`에 넣고 `@Published`로 알리는 패턴을 갖고 있어 여기에 필드를 더한다(4번 예정)

### 구현 (커밋 1~5)
- `Lesson`에 옵셔널 `conceptCard`와 `ConceptCard` 타입 추가 (`160efda`). `var` 옵셔널이라 memberwise init에서 기본값 `nil`이 생겨 **기존 레슨 5개의 선언은 한 글자도 바뀌지 않았다.** 도식은 그림 파일이 아니라 그리는 관계(`Diagram`: `pointerToValue`/`pointerToPointer`/`pointerChain`)로 표현했다
- `MemoryItem`에서 표시 전용 `MemorySlotView` 분리 (`2c5cbf3`). `slot` 하나만 받아 `vm` 없이 그릴 수 있고, `MemoryItem`은 `.draggable`/`.dropDestination`만 얹는다. **`.shadow`는 `draggable` 뒤에 붙는 기존 순서를 유지**해 드래그 프리뷰 스냅샷이 달라지지 않게 했다(그림자는 §2의 슬롯 표기에 없는 그리드 전용 요소이기도 하다)
- 화살표 표기를 `PointerArrow`로 추출 (`f7ee54c`). `ArrowDrawLayer`는 좌표 계산과 `spring` 애니메이션만 남기고 그리기를 위임한다
- 개념 카드 시트 `ConceptCardView` 신설 (`c51f3a0`). 그래버·버튼 스타일은 `OnboardingView`/`WelcomeView`의 기존 시트 관례를 따랐고, 서브뷰는 `STYLE_GUIDE.md` §4대로 `private extension`의 대문자 계산 프로퍼티로 뺐다
  - 도식의 화살표 좌표를 그리드 화면과 **같은 방식**(`BoundsPreferenceKey` + `overlayPreferenceValue`)으로 실제 배치에서 얻는다. 열 수나 칸 너비를 바꿔도 화살표가 따라온다
  - 도식의 주소·변수명은 `MemoryGridVM.resolveVariableName`이 실제로 부여하는 값과 맞췄다 — 레슨 1 `p1(0x7020) → target(0x700C)`, 레슨 2 `p1(0x7038) → ptr1(0x7014) → target(0x701C)`, 레슨 3 `start → nodeA → nodeB → treasure`
  - 레슨 3만 4칸이라 한 줄에 넣으면 칸이 좁아져 2행으로 배치했다
- 커밋마다 `xcodebuild ... build` → 전부 **BUILD SUCCEEDED**. 새 파일 3개는 `project.pbxproj` 4곳(`PBXBuildFile`/`PBXFileReference`/그룹 children/Sources)에 수동 등록하고 `plutil -lint`로 검증했으며, **빌드 산출물에 `*.stringsdata`가 생겼는지로 실제 컴파일 대상 포함 여부까지 확인**했다 — 등록이 누락되면 빌드는 통과하면서 파일만 조용히 빠진다
- `PointerArrow`와 `ConceptCardView`는 `project.pbxproj` 변경이 한 파일에 섞여 있어, ConceptCardView 관련 4줄을 일시적으로 덜어낸 상태로 앞 커밋을 만들고 되돌린 뒤 뒤 커밋을 만들어 **두 커밋 모두 그 자체로 빌드 가능**하게 나눴다

### 구현 (커밋 6~11)
- 열람 기록을 `LessonProgressStore`에 추가 (`ca6d26a`). 새 저장소를 만들지 않고 `completedLessonIds`와 같은 `Set<Int>` + `UserDefaults` 패턴에 필드를 더해 직렬화 코드가 한 곳에만 남는다
- `MemoryGridView` 연동 (`a373053`). **띄우는 시점에 곧바로 열람으로 기록**해 "시작하기"로 닫든 스와이프로 닫든 재진입 시 다시 뜨지 않는다. `(i)`는 힌트·리셋보다 앞에 선언해 이미 익숙한 리셋 버튼이 오른쪽 끝에 그대로 남게 했다. `conceptCard`가 `nil`인 레슨 0·샌드박스는 버튼도 시트도 나타나지 않아 뷰에 레슨 id 분기가 없다
- 레슨 1~3 문구·도식 등록 (`53fd14f`). `PLAN.md` 백로그 B가 지목한 오개념 3가지를 카드마다 하나씩 겨냥했다 — 레슨 1은 복사와 별칭의 차이, 레슨 2는 포인터와 피포인티의 구분, 레슨 3은 중간 노드가 값을 갖고 있다는 오해. 레슨 1만 5문장인 것은 `*`와 `&`를 **둘 다** 설명하고 "왜 주소를 쓰는가"에 답해야 하기 때문이다(초안은 `&`만 설명했는데, 기호 하나만 풀어주면 나머지 하나가 설명되지 않은 채 남는다)
  - 문장 속 C 조각은 백틱으로 감쌌다. Task 9에서 `Text`가 `*`/`**`를 마크다운 강조로 오인식해 글자가 사라진 전례가 있어, **`AttributedString(markdown:)`으로 직접 파싱해 백틱 안의 `**`가 살아남는 것을 확인한 뒤** 채택했다
  - 레슨 2의 `hintCode`를 `int **pp = &p;` → `int **p1 = &ptr1;`로 고쳐 힌트·그리드 라벨·개념 카드가 같은 이름을 쓰게 했다
- 로컬라이제이션 (`0af3599`, `138f9f0`). 신규 15개의 `en` 번역을 채우고 쓰이지 않게 된 옛 힌트 1개를 삭제했으며, 방출된 키와 컴파일된 키를 대조해 15개 모두 일치함을 확인했다
  - `.xcstrings`는 Xcode 고유 서식(`" : "` 구분자)이라 일반 JSON 덤프로 저장하면 파일 전체가 diff로 잡힌다. **원본을 그대로 재직렬화해 바이트 단위로 같은지 먼저 검증한 뒤** 편집했고, 기존 키 순서를 건드리지 않아 diff가 순수 추가·삭제만 남는다
  - `ConceptCardView`의 `#Preview`에 인라인으로 적은 더미 문구가 그대로 로컬라이즈 키로 방출되고 있었다. `STYLE_GUIDE.md` §10대로 `LessonData`의 실제 레슨을 쓰도록 바꿔 화면에 없는 키 2개를 없앴다

### 1차 사용자 검증 결과 (2026-09-06)
- **도식에서 주소·변수명이 말줄임표로 잘리는 문제 발견 → 수정 후 해소 확인.** 원인은 폭이었다. 레슨 2 도식이 3열이라 칸당 84pt였고, `0x703C`+`treasure` 조합은 좌우 패딩을 빼면 약 124pt가 필요하다
  - `MemorySlotView`의 라벨에 `lineLimit(1)` + `minimumScaleFactor(0.6)`을 적용해 **자르는 대신 글자를 줄이도록** 했다. 주소와 변수명은 잘리면 안 되는 정보다 — 레슨 0이 가르친 "모든 칸에는 번호가 있다"가 `0x70...`으로 보이면 의미가 사라진다. 이 수정은 그리드 화면에도 함께 적용되어, 레슨 3의 `treasure` 칸이 잘리던 것도 같이 해소된다
  - 개념 카드 도식을 **2열 고정**(`.flexible(maximum: 150)`)으로 바꿔 애초에 좁아지지 않게 했다. `columns`/`slotWidth` 파라미터가 사라져 호출부도 짧아졌다
- 사용자가 **빈 칸 더블탭 시 빨간 흔들림**이 필요한지 제기 → 별도 Task로 분리하기로 확정. Task 17로 승격해 처리했다(아래 "Task 17 완료" 참고)
- 이어진 검증에서 **자동 노출·`(i)` 버튼·코드 조각 렌더링 3항목 정상 확인** — 레슨 1~3 최초 진입 시 카드가 뜨고 재진입 시에는 뜨지 않으며 `(i)`로 다시 열린다, 레슨 0·플레이그라운드에는 `(i)`가 없다, 문장 속 `int **p1 = &ptr1;`이 등폭으로 보이고 `*`가 사라지지 않는다
  - 마지막 항목은 착수 전 `AttributedString(markdown:)` 파싱으로 예측한 결과가 **실제 렌더링과 일치**했다. 백틱으로 감싸면 Task 9의 마크다운 오인식(글자 사라짐)이 재현되지 않는다는 것이 화면에서도 확인됐다
- 남은 검증은 `MemorySlotView` 분리에 따른 **그리드 회귀** 하나뿐이었다 (`TODO.md`의 "병합 전 남은 확인") → 아래 2차 검증에서 통과

### 2차 사용자 검증 결과 (2026-09-07)
마지막 남은 그리드 회귀 항목이다. **상호작용 검증에 들어가기 전에 정적으로 답할 수 있는 부분을 먼저 좁혔다** — 시뮬레이터에서 볼 것을 줄이면 무엇을 보고 있는지가 분명해진다.

- **분리가 순수 이동임을 기계적으로 확인했다.** 분리 전 `MemoryItem`의 뷰 본문과 현재 `MemorySlotView` + `MemoryItem`을 이어붙인 것에서 모디파이어 이름 순서를 각각 추출해 대조했더니, `7014c98`이 라벨에 더한 `lineLimit`/`minimumScaleFactor` 2개를 빼면 **순서·개수가 완전히 일치**했다. 눈으로 diff를 읽으면 "옮긴 것 같다"까지가 한계인데, 순서를 뽑아 비교하면 `.shadow`가 `.draggable` 뒤에 남아 드래그 프리뷰 대상이 바뀌지 않는다는 것까지 확정된다
- **`treasure` 라벨은 계산으로 먼저 답했다.** 실제 폰트 메트릭(`monospacedSystemFont`)으로 재니 `0x703C`(caption 12pt) 44.5pt + spacing 4pt + `treasure`(caption2 11pt bold) 54.4pt = **102.9pt**가 필요하다. 그리드는 `.adaptive(minimum: 100)`이라 iPhone 폭 전 구간(375~440pt)에서 3열이 되고 라벨 가용 폭은 79.7~101.3pt다 → 적용 배율 **0.77~0.98**로 하한 0.6에 닿지 않아 잘리지 않는다. 개념 카드(2열, 칸 최대 150pt)는 가용 126pt라 축소 자체가 일어나지 않는다
- **체크리스트 한 항목이 애초에 재현 불가능하다는 것을 검증 전에 잡아냈다.** "자기 자신에게 연결 시 빨간 흔들림"은 드래그로 도달할 수 없다 — `MemoryItem.swift:17`이 `draggedAddress != slot.address`일 때만 `handleDrop`을 부르므로 `MemoryGridVM.swift:115-121`의 자기참조 분기는 죽은 코드다. 이 가드는 분리 전에도 동일해 회귀가 아니다. 실제로 도달 가능한 빨간 흔들림은 `MemoryGridVM.swift:197`(포인터가 아닌 칸 더블탭) 하나뿐이라, 회귀 확인 항목을 그쪽으로 **교정한 뒤** 검증에 넘겼다
- 사용자 검증 결과 **6항목 모두 정상** — 드래그·드롭 연결과 프리뷰 그림자, 화살표 선·머리·`spring` 애니메이션, 더블탭 에러 흔들림, 레슨 2 참조 배지, 레슨 0 값 칸 탭·완료 알럿·체크마크, 레슨 3 `treasure` 라벨 크기
- 교훈: **체크리스트 항목이 정말 재현 가능한지부터 코드로 확인한다.** 재현되지 않는 항목을 그대로 넘겼다면 사용자는 "흔들림이 안 난다"를 회귀로 보고했을 것이고, 원래부터 없던 동작을 되살리려 애먼 코드를 고쳤을 것이다

### 발견한 이탈
- 레슨 2 `hintCode` 이름 불일치 → 5번에서 해소 (위 참고)
- `이 슬롯을 드래그해서 저 주소 위에 놓아보세요`(Task 9 `GridInteractionHintOverlay`)에 `en` 번역이 없어 **영어 사용자에게 한국어가 그대로 보인다.** 카탈로그 항목이 `{}`로 비어 있다. 이번 Task 범위 밖이라 손대지 않고 `TODO.md`에 기록만 남겼다
- `handleDrop`의 자기참조 에러 분기가 도달 불가능한 죽은 코드다(위 2차 검증 참고). 같은 `triggerError` 경로를 다루는 다음 Task에서 함께 걷어낸다
- Dynamic Type xxxLarge 이상에서는 `0x703C`+`treasure`의 필요 배율이 0.55까지 떨어져 다시 잘린다(계산값). 수정 전에는 기본 크기에서도 잘렸으므로 이번 변경은 순수한 개선이고, 접근성 크기 대응은 범위 밖이라 기록만 남겼다

## Task 16 완료 (`feature/lesson-concept-cards`)
B-1 레슨별 개념 카드 구현·검증·병합 완료. 세부 내역은 위 "Task 16 진행 상황" 참고. 레슨 1~3이 각각 겨냥한 오개념 하나씩을 문제를 풀기 전에 먼저 짚어준다.

- **커밋 15개** — 코드 10개(`160efda` 데이터 타입 / `2c5cbf3` `MemorySlotView` 분리 / `f7ee54c` `PointerArrow` 추출 / `c51f3a0` 카드 시트 / `ca6d26a` 열람 기록 / `a373053` 화면 연동 / `53fd14f` 문구·도식 / `0af3599`·`138f9f0` 로컬라이제이션 / `7014c98` 라벨 잘림 수정)와 문서 5개(`4ae48aa` Task 등록 / `9d4a513` 진행 내역 / `ab8d984`·`4c3b97a`·`b14ebff` 검증 기록). 빌드 검증은 코드 커밋 10개마다 수행했다
  - 병합 커밋 메시지에는 커밋 수를 12개로 적었다. 실제는 15개다. 이미 푸시된 병합 커밋이라 히스토리를 다시 쓰지 않고 여기에 정확한 수를 남긴다
- `develop`에 `--no-ff` 병합(병합 커밋 `0be654e`), 병합 직후 `xcodebuild ... build` → BUILD SUCCEEDED 재검증, `origin/develop` 푸시(`431cfc3..0be654e`), 로컬·원격 feature 브랜치 삭제 완료
- **로컬 브랜치 삭제 순서에 걸림돌이 하나 있었다.** 로컬이 원격 feature 브랜치보다 2커밋 앞서 있어 `git branch -d`가 "not fully merged"로 거부했다 — `develop`에는 병합됐지만 자기 upstream에는 반영되지 않은 상태였기 때문이다. `-D`로 강제하는 대신 **원격 브랜치를 먼저 지워 upstream 자체를 없앤 뒤** `-d`를 다시 실행했다. 강제 삭제는 "정말 병합됐는가"라는 확인을 건너뛰지만, 이 순서는 그 확인을 그대로 통과한다
- 새 파일 3개(`MemorySlotView`/`PointerArrow`/`ConceptCardView`)가 생겼고 기존 `MemoryItem`·`ArrowDrawLayer`는 각각 절반 이하로 줄었다. **도식을 그림 파일로 만들지 않기로 한 결정의 결과다** — 카드와 그리드가 같은 컴포넌트를 쓰므로 표기가 어긋날 여지가 없고, `7014c98`의 라벨 축소 수정 하나가 양쪽에 동시에 적용됐다
- 1.0 출시 전 항목 3번(학습 효과 보강)의 3개 중 **B-1·B-2 완료**, B-4만 남았다

## Task 17 진행 상황 (`feature/empty-slot-tap-feedback`)
빈 칸 더블탭 시 나오던 에러 피드백(빨간 배경 + 흔들림)을 걷어냈다. Task 16 검증 중 사용자가 제기한 항목을 병합 후 별도 브랜치로 착수(2026-09-07). 배경·판단은 `TODO.md` Task 17 절 참고.

### 구현 (커밋 3개)
- **빈 칸 가드 추가** (`c1dc55a`). 기존 `guard`를 고치지 않고 **그 앞에 빈 칸만 걸러내는 가드**를 두었다. 값 칸(`*a`는 실제 C 컴파일 에러)과 아직 아무 곳도 가리키지 않는 포인터(초기화되지 않은 역참조 경고)가 타던 경로는 한 글자도 바뀌지 않아, 남겨야 할 두 에러를 건드릴 위험이 없다
- **도달 불가능한 자기참조 분기 제거** (`bafff62`). 지운 자리에 "자기 자신에게 드롭한 경우는 호출부(`MemoryItem`)가 걸러내므로 두 주소는 항상 다르다"를 문서 주석으로 남겼다 — **코드를 지우면 그 코드가 담고 있던 전제도 함께 사라진다.** 방어 코드로 두지 않은 이유는 이 분기가 no-op이 아니라 빨간 흔들림을 띄우기 때문이다. 호출부 가드가 나중에 사라지면 이번 Task가 없애려는 피드백이 그대로 되살아난다
- **stale 문구 삭제** (`59d8fdb`). 재직렬화가 원본과 바이트 단위로 같은지 `assert`로 먼저 통과시킨 뒤 편집해 diff가 순수 삭제 16줄만 남았다. Xcode 고유 서식 두 가지를 맞춰야 했다 — 빈 객체를 `{}`가 아니라 `{\n\n<들여쓰기>}`로 쓰고, **파일 끝에 개행이 없다**
- 커밋마다 `xcodebuild ... build` → 전부 **BUILD SUCCEEDED**

### 사용자 검증이 코드를 바꾼 지점
1단계 직후 "흔들림은 없어졌는데 `codeLog`가 바뀌지 않는다"는 보고가 왔다. **문제가 아니라 내가 쓴 문구가 덮어써지고 있다는 신호였다.**

- 더블탭에는 `MemoryGridView`의 `onTapGesture`와 `simultaneousGesture(TapGesture(count: 2))`가 **함께 발화**한다. `handleTap`의 빈 슬롯 분기가 `codeLog = "// 주소: 0x70XX"`를 쓰는데, 이것이 `dereference`보다 나중에 실행돼 새 문구를 지웠다. 안 바뀐 것처럼 보인 이유는 첫 번째 탭에서 이미 같은 주소 문구가 찍혀 있었기 때문이다
- 문구를 되살리는 대신 **`dereference`에서 `codeLog`를 아예 쓰지 않도록** 했다. 두 제스처의 실행 순서는 SwiftUI가 보장하지 않아, 지금은 `handleTap`이 이기지만 순서가 뒤집히면 같은 조작에 다른 문구가 나오는 재현하기 어려운 버그가 된다
- 부수 효과로 **신규 로컬라이즈 키가 0건**이 됐다. `en` 번역 추가가 사라지고 stale 키 1개 삭제만 남아 예상 커밋 수가 4개에서 3개로 줄었다
- 교훈: **"동작은 맞는데 화면이 그대로다"는 보고는 실행 순서를 알려주는 단서다.** 눈에 보이는 증상만 고쳤다면 순서에 의존하는 코드가 그대로 남았을 것이다

### 사용자 검증 결과 (2026-09-07)
- **4항목 모두 정상** — 빈 칸 더블탭 시 흔들림 없이 주소 한 줄만 표시, 값 칸과 가리키는 곳 없는 포인터의 에러 피드백 유지, 정상 포인터 역참조와 드래그·드롭 회귀 없음
- 이번 Task에서 **동작이 바뀔 수 있는 유일한 지점은 자기참조 분기 제거**였다. 정적 분석으로 "도달할 수 없다"고 판단하고 지웠으므로, 자기 자신에게 드롭했을 때 빨간 흔들림이 나오면 판단이 틀린 것이었다. 검증에서 아무 일도 일어나지 않음이 확인돼 판단이 실제 동작과 일치했다

### 검증 중 걸린 함정
`.stringsdata`를 전부 모아 보면 삭제한 키가 아직 방출되는 것처럼 보인다. 원인은 DerivedData에 남은 **x86_64 슬라이스**로, 전날 빌드의 잔재다. 오늘 빌드는 arm64만 갱신되므로 **아키텍처별로 나눠 mtime과 함께** 봐야 한다. arm64 기준으로는 방출 키 89개 중 카탈로그에 없는 것이 `int *p = &a;`(프리뷰 전용, 기록해 둔 무해 항목) 하나뿐이고, 카탈로그에만 남아 쓰이지 않는 키는 0건이다. 빌드 산출물의 `en`/`ko`에도 삭제한 키가 없다.

## Task 17 완료 (`feature/empty-slot-tap-feedback`)
빈 칸 더블탭 에러 피드백 제거 구현·검증·병합 완료. 세부 내역은 위 "Task 17 진행 상황" 참고.

- 커밋 4개 — `c1dc55a` 빈 칸 가드 / `bafff62` 죽은 분기 제거 / `59d8fdb` stale 문구 삭제 / `1b4a4a1` 문서. 코드 커밋 3개마다 빌드 성공을 확인했다
- `develop`에 `--no-ff` 병합(병합 커밋 `cd75c51`), 병합 직후 `xcodebuild ... build` → BUILD SUCCEEDED 재검증, `origin/develop` 푸시(`0be654e..cd75c51`), 로컬 브랜치 삭제 완료
- **브랜치를 원격에 올리지 않고 진행해 정리가 단순했다.** Task 16에서 `git branch -d`가 "not fully merged"로 거부당한 원인이 로컬과 원격 feature 브랜치의 간극이었는데, 애초에 원격 브랜치를 만들지 않으면 그 간극 자체가 생기지 않는다. 혼자 작업하는 feature 브랜치는 굳이 올릴 필요가 없다
- **코드 변경은 두 파일뿐이다** — `MemoryGridVM.swift`(+10/−13), `Localizable.xcstrings`(−16). 새 파일도, 새 로컬라이즈 키도 0건이다. 착수 시점 예상은 커밋 4개·30~40분이었고 실제 커밋 수는 같았지만, 검증 중 `codeLog` 쓰기를 빼기로 하면서 가장 부담이 크던 로컬라이제이션 단계가 통째로 사라졌다
- 1.0 출시 전 항목 3번(학습 효과 보강)은 **B-4만 남았다**

## Task 18 진행 상황 (`feature/lesson-summary`)
B-4 레슨 마무리 요약. 완료 알럿에 "이번에 배운 것" 한 문장과 다음 레슨 연결을 붙였다(2026-09-08). 착수 전 결정 3건과 작업 항목은 `TODO.md` Task 18 절 참고.

### 구현 (커밋 6개)
- **요약 문구 데이터** (`3bed136`). `Lesson`에 옵셔널 `summary`를 둬 `conceptCard`와 같은 패턴을 따랐다. 값이 없으면 알럿이 지금과 똑같이 제목만 표시하므로, 샌드박스와 Coming Soon 레슨을 id로 걸러내는 분기가 필요 없다
- **알럿 `message`에 요약 표시** (`2205bdd`)
- **`MainView`의 `path` 상태 도입** (`89b941b`). 화면 동작이 바뀌지 않는 준비 단계로 따로 끊었다. `MemoryGridView`의 `path` 바인딩에 `.constant([])` 기본값을 둬 프리뷰와 기존 호출부가 그대로 컴파일된다
- **"다음 레슨" 버튼과 챕터 완료 문구** (`f026f2f`). `nextLesson(after:)`가 다음이 `isComingSoon`이면 `nil`을 돌려주므로 레슨 3에서 버튼이 자동으로 사라진다. 챕터 번호는 `chapter(of:)`로 구해 하드코딩하지 않았다
- **`en` 번역 6건** (`31e0d9a`). 재직렬화가 원본과 바이트 단위로 같은지 확인한 뒤 편집해 diff가 순수 추가 96줄만 남았다
- **이동 버그 수정** (`186c4e3`). 아래 "사용자 검증이 코드를 바꾼 지점" 참고
- 커밋마다 `xcodebuild ... build` → 전부 **BUILD SUCCEEDED**

### 사용자 검증이 코드를 바꾼 지점
"레슨 0에서 다음 레슨 버튼을 눌러도 레슨 1로 가지 않는다"는 보고가 왔다. `path`는 정상적으로 바뀌고 있었으므로 **이동이 실패한 것이 아니라 화면이 갱신되지 않은 것**이었다.

- `@StateObject`의 수명은 **뷰 identity**에 묶인다. `path`의 마지막 원소를 교체하면 스택 깊이도 뷰 타입도 그대로라 SwiftUI는 같은 뷰로 판단하고 `init(lesson:)`을 다시 부르지 않는다. 그 결과 `path`는 레슨 1을 가리키는데 화면은 레슨 0의 VM(제목·그리드·성공 조건 전부)을 계속 들고 있었다
- `navigationDestination` 목적지에 `.id(lesson.id)`를 줘 레슨마다 identity를 분리했다. VM을 갈아 끼우는 `onChange` 방식도 가능하지만, 그 경우 `onAppear`가 다시 발화하지 않아 **다음 레슨의 개념 카드가 자동으로 뜨지 않는다.** identity를 분리하면 Task 16이 만든 자동 노출이 그대로 살아난다
- 교훈: **"버튼이 동작하지 않는다"가 항상 동작의 문제인 것은 아니다.** 상태는 바뀌었는데 그 상태를 읽는 쪽의 수명이 더 길면 화면만 과거에 머문다

### 검증 중 걸린 함정
`Text("\n\n")`이 줄바꿈 자체를 로컬라이즈 키로 방출하고 있었다. 빌드 산출물의 `.stringsdata`를 열어 방출 키를 확인하다 발견했고 `Text(verbatim:)`으로 바꿨다. **로컬라이즈 여부는 코드만 봐서는 드러나지 않는다** — `Text("...")`은 문자열의 성격과 무관하게 전부 추출 대상이다. 최종 대조에서 카탈로그에만 남아 쓰이지 않는 키는 0건, 카탈로그에 없는 방출 키는 기록해 둔 프리뷰 전용 `int *p = &a;` 하나뿐이다.

### 사용자 검증 결과 (2026-09-08)
- 레슨 0~3 전 구간을 "다음 레슨"으로 끊김 없이 이어서 진행, 레슨 3에서 버튼 없이 챕터 완료 문구 표시, 뒤로가기 한 번에 목록 복귀, 플레이그라운드 회귀 이상 없음

## Task 18 완료 (`feature/lesson-summary`)
B-4 레슨 마무리 요약 구현·검증·병합 완료. 세부 내역은 위 "Task 18 진행 상황" 참고.

- 커밋 7개 — 코드 6개(`3bed136` 요약 데이터 / `2205bdd` 알럿 표시 / `89b941b` path 상태 / `f026f2f` 다음 레슨 버튼 / `31e0d9a` en 번역 / `186c4e3` 이동 버그 수정)와 문서 1개(`ffbbe1a`). 코드 커밋마다 빌드 성공을 확인했다
- `develop`에 `--no-ff` 병합(병합 커밋 `d13fec7`), 병합 직후 `xcodebuild ... build` → BUILD SUCCEEDED 재검증, `origin/develop` 푸시(`cd75c51..d13fec7`), 로컬 브랜치 삭제 완료. Task 17에 이어 원격 feature 브랜치를 만들지 않아 정리가 단순했다
- **푸시에 Task 17 문서 커밋(`4104a55`)이 함께 올라갔다.** 지난 Task의 마지막 문서 커밋이 로컬에만 남아 있었다 — 병합 전 `git status -sb`로 푸시 대상을 확인하지 않았다면 모르고 지나갈 뻔했다
- **1.0 출시 전 항목 3번(학습 효과 보강)이 완료됐다.** B-2(Task 15) → B-1(Task 16) → B-4(Task 18) 세 항목이 모두 닫혔고, 별도 이론 화면 없이 레슨 흐름 안에서 개념을 설명한다는 2026-08-14의 방향이 그대로 지켜졌다 — 진입 전 개념 카드, 레슨 중 그리드 조작, 완료 후 요약 한 문장

### 발견한 이탈
- **영어 목록 화면에서 레슨 설명이 잘린다.** 검증 중 사용자가 영어 환경에서 발견했다. `LessonRow`의 `.lineLimit(2)`가 한국어 줄 수에 맞춰져 있어, 문장 하나가 2줄을 쓰는 영어에서는 **레슨 1·2의 조작 안내 문장이 통째로 사라진다.** Task 19로 승격했다 (`TODO.md` Task 19 절)

## Task 19 진행 상황 (`feature/lesson-row-description`)
목록 행의 설명이 영어에서 잘리던 문제를 고쳤다(2026-09-08). Task 18 검증 중 사용자가 영어 환경에서 발견한 항목을 병합 후 별도 브랜치로 착수했다. 배경·방향은 `TODO.md` Task 19 절 참고.

### 구현 (커밋 1개)
- **행에 첫 문장만 표시** (`4c92658`). `String(localized:)`로 해석한 뒤 `\n` 기준 첫 줄만 쓴다. **문구도 번역도 한 건 바뀌지 않았고 신규 로컬라이즈 키도 0건이다** — 데이터를 고치지 않고 보여주는 방식만 바꿨다
- `lineLimit(2)`는 남겨 두었다. 영어 첫 문장이 두 줄을 쓰는 레슨 1·2를 그대로 수용하면서, 나중에 더 긴 문구가 들어와도 행 높이 상한이 유지된다

### 왜 줄 수 제한을 푸는 대신 문장 단위로 잘랐나
- **줄 수는 언어에 따라 달라지는 값이다.** `lineLimit(2)`는 한국어(문장당 한 줄) 기준으로 맞춰 둔 값이라 영어(문장당 두 줄)에서 깨졌다. 제한을 4줄로 늘려도 언어가 하나 더 늘면 같은 문제가 반복된다
- 문장 단위로 자르면 **몇 줄로 그려지든 의미가 잘리지 않는다.** 기기 폭이나 Dynamic Type이 바뀌어도 마찬가지다
- 잃는 것은 목록에서의 조작 안내 한 문장인데, 이것은 레슨에 들어가면 `LessonHeaderView`가 줄 수 제한 없이 전문으로 보여준다. **목록은 고르는 화면이고 읽는 화면이 아니다**

### 검증 결과 (2026-09-08)
- 영어·한국어 목록 화면을 촬영해 대조했다. 영어 레슨 1·2에서 사라졌던 문장이 온전히 표시되고, 목록 전체에 `…`가 한 곳도 남지 않았다. 사용자가 영어 목록에서 해결을 확인했다
- 한국어는 행이 두 줄에서 한 줄로 짧아졌다. **의도한 수정이 아니라 부수 효과지만, 한 화면에 챕터 2까지 들어와 목록의 훑어보기가 오히려 나아졌다**

## Task 19 완료 (`feature/lesson-row-description`)
목록 행 설명 문구 잘림 수정 구현·검증·병합 완료. 세부 내역은 위 "Task 19 진행 상황" 참고.

- 커밋 2개 — 코드 1개(`4c92658`)와 문서 1개(`8730f26`). 코드 변경은 **한 파일 +12/−1**이 전부다
- `develop`에 `--no-ff` 병합(병합 커밋 `9bd2e7a`), 병합 직후 `xcodebuild ... build` → BUILD SUCCEEDED 재검증, `origin/develop` 푸시(`d13fec7..9bd2e7a`), 로컬 브랜치 삭제 완료
- 레슨 진입 후 헤더에 두 문장이 모두 보이는 것까지 사용자가 확인했다. **목록에서 뺀 문장이 사라진 것이 아니라 자리를 옮긴 것**임이 확인된 셈이다
- **영어로 한 번 써 본 것이 이 Task를 만들었다.** 한국어로만 확인하면 `lineLimit(2)`는 완벽해 보인다. 남은 화면(설정·온보딩·개념 카드·완료 알럿)도 같은 방식으로 훑어볼 가치가 있고, 1.0 4번의 "지원 언어" 점검과 성격이 겹치므로 그때 함께 본다
- **1.0 출시 전 항목 1~3번이 모두 완료됐다.** 남은 것은 4번 하나다

## 1.0 4번 착수 전 결정 (2026-09-09)
Task 19까지의 로컬 문서 커밋 3개를 `origin/develop`에 푸시하고(`9bd2e7a..8e3f1f9`), App Store 심사 대비 항목의 착수 전 결정을 확정했다. 실측 근거와 결정 상세는 `PLAN.md`의 "백로그 D", 작업 분할은 `TODO.md`의 "다음 단계" 참고.

### 실측이 문서의 전제를 두 곳에서 뒤집었다
- **앱 아이콘은 이미 있었다.** `VISUAL_LANGUAGE.md` §9의 "이번 범위에서 다루지 않는다"를 미제작으로 읽고 있었으나, `AppIcon.appiconset`에 1024px 3종(Default/Dark/TintedLight)이 2026년 7월자로 들어 있다. 그림도 확정된 도식 표기 규칙(화살표 = 포인터, 초록 테두리 = 성공)과 어긋나지 않는다
- **스크린샷 부담은 언어가 아니라 기기에서 왔다.** 착수 전 결정 항목은 "언어 조합이 배가된다"로 적혀 있었지만, 실제 부담은 `TARGETED_DEVICE_FAMILY`가 `1,2`인 유니버설 설정이었다. **iPad 대응 분기는 코드에 0건인데 iPad 스크린샷은 심사에 필요하다** — 대응하지 않은 기기를 지원 목록에 올려 둔 상태였다

### 결정 4건
- **아이콘·색 팔레트 모두 재제작** — 현행 유지가 가장 싼 선택지였으나 사용자가 재제작을 선택했다. 브랜딩이 첫 Task가 되고 스크린샷이 마지막이 된다
- **개인정보처리방침은 GitHub Pages** — 네트워크 코드가 0건이고 저장은 `LessonProgressStore`의 `UserDefaults` 두 키뿐이라 "수집 없음"으로 끝난다. 기존 공개 저장소를 그대로 쓴다
- **1.0은 iPhone 전용** — `TARGETED_DEVICE_FAMILY`를 `1`로 축소한다. iPad 검수 Task와 iPad 스크린샷이 통째로 사라지고, iPad 지원은 레이아웃을 손본 뒤 1.x로 미룬다
- **스크린샷은 한국어·영어 둘 다** — 기기 축을 하나로 줄인 만큼 언어 축 두 개는 감당할 수 있다

## Task 20 진행 상황 (`feature/branding-rework`)
브랜딩 재제작(2026-09-09). 방향 3건(파랑 유지·모티프 유지·다크 모드 포함)을 정한 뒤 착수했다. 배경과 작업 항목은 `TODO.md` Task 20 절 참고.

### 구현 (커밋 6개)
- **팔레트 값 교체와 다크 변형**(`36e0a3c`) — `Main`을 `#007FFF`에서 `#2563EB`로 낮췄다. 이전 값은 채도만 높고 어둡지 않아 흰 배경 위 텍스트로 쓰기에 대비가 모자랐다. **`Main`은 변수명 라벨·포인터 내용·힌트 문구에 텍스트로 쓰인다** — 테두리 색으로만 생각하면 놓치는 제약이다
- **코드 패널 키워드 분리**(`7074948`) — `Main`을 어둡게 만든 대가가 여기서 나왔다. 코드 패널은 시스템 모드와 무관하게 항상 어두운 배경이라, 라이트 기준으로 어두워진 `Main`을 키워드에 그대로 쓰면 읽히지 않는다. §6이 에디터 팔레트를 별도 축으로 이미 분리해 뒀는데 키워드만 색을 공유하고 있었다
- **완료 체크마크**(`c35d6e5`) — 시스템 `.green`을 자산 `Green`으로 교체. §7 이탈 목록에 있던 항목이다
- **앱 강조색 지정**(`2403d99`) — **강조색을 지정한 적이 한 번도 없었다.** 탭 바·버튼·링크가 시스템 기본 파랑을 쓰고 있어, 새 `Main`으로 바꾸자 한 화면에 파랑이 두 종류 보였다. 최상위 `TabView`에 한 번 지정해 해결했다
- **장식 축 분리**(`525a6d0`) — 챕터별 아이콘 색이 `Green`(값)·`Red`(에러)를 빌려 쓰던 이탈을 닫았다. 챕터 구분을 색에서 심볼로 옮기고 아이콘은 브랜드 파랑 하나로 통일했다. 같은 이탈인데 목록에 없던 샌드박스 진입점(`Yellow` 사용)도 함께 찾아 장식 전용 `Deco`/`LightDeco`로 옮겼다
- **앱 아이콘 재제작**(`81c3150`) — 모티프는 유지하고 색·마감만 바꿨다. 목표 칸의 별을 값 토큰(초록 테두리 + 채워진 사각형)으로 교체했다 — 별은 도식 표기 규칙에 없는 기호이고 게임 시절의 잔재다. 화살표는 빈 칸 위를 가로지르지 않고 칸 사이 간격을 따라 지나게 다시 그렸다

### 왜 자산이 10개에서 8개로 줄었나
장식 축을 정리하자 `LightGreen`·`LightRed`·`LightYellow`의 쓰임이 한꺼번에 사라졌다. 참조가 0건이던 `LightBlown`·`Text1`과 함께 제거하고, 장식 전용 `Deco`/`LightDeco`와 `CodeKeyword`를 새로 뒀다. **색이 줄어든 것이 아니라 축이 정리된 것이다** — 종류 2개, 상태 2개, 장식 3개, 에디터 1개로 각 색이 정확히 한 축에 속한다.

### 검증
- 커밋마다 `xcodebuild ... build` → BUILD SUCCEEDED
- 목록 화면을 라이트·다크로 촬영해 대조했다. 탭 바 아이콘 픽셀을 찍어 `#2563EB`로 강조색이 실제 적용된 것까지 확인했다
- 홈 화면에 설치해 새 아이콘이 작은 크기에서 읽히는지 확인했다
- **레슨 안쪽 화면은 조작이 필요해 사용자가 확인했다**(2026-09-09). 그리드·개념 카드·코드 패널·샌드박스 진입점 모두 통과

### 검증에서 나온 질문 두 가지
- **값 칸 더블 탭이 빨강으로 깜빡이는 것은 의도된 동작이다.** 더블 탭은 역참조이고 값 칸에 `*a`를 쓰는 것은 실제 C에서 컴파일 에러다. 팔레트 교체로 생긴 회귀가 아니다. 다만 깜빡이는 동안 초록 테두리가 빨강으로 덮이는 것은 §7에 남아 있는 이탈이며, 조건식을 고쳐야 하는 항목이라 Task 20 범위 밖이다. **에러 색이 진해지면서 이 이탈이 이전보다 눈에 잘 띄게 됐다** — 승격 시점을 앞당길 근거가 된다
- **앱 이름·아이콘이 포인터에 묶여 있는 문제는 1.0 현행 유지로 정했다.** 1.0의 내용이 실제로 포인터뿐이고, 이름 변경 비용은 나중에도 같다. 근거와 다시 볼 시점은 `PLAN.md` 백로그 D 참고

## Task 20 완료 (`feature/branding-rework`)
브랜딩 재제작 구현·검증·병합 완료. 세부 내역은 위 "Task 20 진행 상황" 참고.

- 커밋 8개 — 코드·자산 6개(`36e0a3c` 팔레트 / `7074948` 코드 패널 키워드 / `c35d6e5` 체크마크 / `2403d99` 강조색 / `525a6d0` 장식 축 / `81c3150` 아이콘)와 문서 2개(`862122f`, `426db08`). 코드 커밋마다 빌드 성공을 확인했다
- `develop`에 `--no-ff` 병합(병합 커밋 `8f67275`), 병합 직후 `xcodebuild ... build` → BUILD SUCCEEDED 재검증, `origin/develop` 푸시(`ea5748f..8f67275`), 로컬 브랜치 삭제 완료
- **문서 커밋을 로컬에 남기지 않았다.** Task 18·19에서 지난 Task의 문서 커밋이 로컬에 남아 다음 푸시에 딸려 올라간 일이 반복됐는데, 이번에는 병합 전에 `git status -sb`로 확인하고 넘어갔다
- **App Store 심사 대비의 선행 Task가 닫혔다.** 아이콘·색이 확정됐으므로 스크린샷을 두 번 찍을 이유가 사라졌다

## Task 21 진행 상황 (`feature/iphone-only-target`)
1.0 지원 기기를 iPhone 전용으로 축소(2026-09-09). 배경은 `TODO.md` Task 21 절 참고.

### 구현 (커밋 1개)
- **기기 범위 축소**(`ca7ae62`) — `project.yml`·`Info.plist`·`project.pbxproj` 세 곳의 `TARGETED_DEVICE_FAMILY`를 `1`로 맞추고, 쓰임이 사라진 `UISupportedInterfaceOrientations~ipad`를 뺐다. 코드 변경은 0건이다

### pbxproj를 손으로 고친 이유
`project.pbxproj`는 xcodegen이 `project.yml`에서 생성하지만 **재생성하면 파일 참조 UUID를 새로 뽑아 파일 전체가 바뀐다.** 값 두 개 때문에 전면 재작성 diff를 남길 이유가 없어 손으로 맞췄다. 대신 저장소 사본에서 xcodegen을 돌려 대조했고, 생성된 pbxproj의 해당 값과 `Info.plist` 전체가 일치했다.

### 검증
- `xcodebuild -showBuildSettings`에서 `TARGETED_DEVICE_FAMILY = 1` 확인. **설정 파일만 고치는 작업이라 파일을 읽어 확인하는 것으로는 부족하고, 빌드가 실제로 어떤 값을 쓰는지 봐야 한다**
- `xcodebuild ... build` → BUILD SUCCEEDED

## Task 21 완료 (`feature/iphone-only-target`)
- 커밋 2개 — 설정 1개(`ca7ae62`)와 문서 1개(`c4922de`). **코드 변경은 0건**이다
- `develop`에 `--no-ff` 병합(병합 커밋 `9d7c2d7`), 병합 직후 빌드 성공 재확인, `origin/develop` 푸시(`09a2638..9d7c2d7`), 로컬 브랜치 삭제 완료

## Task 22 진행 상황 (`feature/english-audit`)
영어 환경 점검(2026-09-09). Task 19를 만든 것과 같은 종류의 문제를 스크린샷 전에 찾는다. 배경과 항목은 `TODO.md` Task 22 절 참고.

### 화면을 열어 보기 전에 카탈로그를 먼저 읽었다
Task 19는 영어 화면을 눈으로 보다가 발견했다. 그 방식은 **그 화면에 가야만 보이는 문제**를 찾는다. 이번에는 순서를 뒤집어 문자열 카탈로그 94개 키를 기계적으로 훑는 것부터 했다.

- 영어 번역이 비어 있는 키는 10개였지만, 언어 중립인 것(빈 문자열, `%lld`, `→ %@`, `int *%@ = &%@;`, `Pointer Quest`)을 빼면 **실제 누락은 2건**이었다
- **그중 하나가 레슨 1의 드래그 안내 오버레이다.** 앱을 처음 여는 영어 사용자가 레슨 1에서 가장 먼저 보는 힌트인데 한국어로 떴다. 눈으로 훑는 방식으로는 레슨 1에 들어가 첫 진입 상태를 만들어야만 보인다
- 나머지 하나는 이중 포인터를 역참조했을 때의 코드 로그로, 레슨 2에서 특정 조작을 해야 나온다

### 구현 (커밋 2개)
- **번역 누락 2건**(`7f6b23d`)
- **문법·용어 4건**(`e9cd8ea`) — 한국어를 그대로 옮기며 관사와 복수형이 빠진 자리다. 탭 라벨 `Setting`은 iOS 관례상 `Settings`가 맞고, 튜토리얼 안내 문구가 같은 이름을 가리키므로 함께 맞췄다

### 잘림 위험은 이미 닫혀 있었다
산문에 줄 수 제한을 거는 곳은 `LessonRow` 하나뿐이고 Task 19에서 고쳤다. `MemorySlotView`의 `lineLimit(1)`은 주소·변수명에 걸려 있어 **언어 중립이라 번역과 무관하다.** 영어 목록을 다시 찍어 `…`가 한 곳도 없음을 확인했다.

### 발견한 이탈 (Task 20 후속)
**시트 안에서는 강조색이 브랜드 색으로 바뀌지 않는다.** 영어 환영 시트의 "No, I'm good." 링크 픽셀을 찍어 보니 `#007AFF`(시스템 파랑)였다. `AppView`의 `TabView`에 건 `.tint`가 시트로 전파되지 않는다. 온보딩과 개념 카드가 전부 시트라 **Task 24 스크린샷 전에 닫아야 한다.** 영어 문제가 아니므로 Task 26으로 승격했다.

### 검증
- 커밋마다 빌드 성공. 영어 목록 화면을 수정 전후로 촬영해 대조했다
- **조작이 필요한 영어 화면 5개(설정·온보딩·개념 카드·완료 알럿·레슨 1 드래그 안내)는 사용자가 확인했다**(2026-09-09). 보고된 문제 없음
- **카탈로그를 먼저 훑은 것이 실제로 두 건을 건졌다.** 사용자가 확인한 5개 화면에서는 새 문제가 나오지 않았다 — 눈으로 보는 검증만 했다면 레슨 1 드래그 안내의 한국어 노출은 그 화면을 첫 진입 상태로 만들어야만 걸렸을 것이다

## Task 22 완료 (`feature/english-audit`)
- 커밋 4개 — 문구 2개(`7f6b23d` 번역 누락 / `e9cd8ea` 문법·용어)와 문서 2개(`a799723`, `01c6cb9`). **코드 변경은 0건이고 전부 문자열 카탈로그다**
- `develop`에 `--no-ff` 병합(병합 커밋 `7760ba6`), 병합 직후 빌드 성공 재확인, `origin/develop` 푸시(`9d7c2d7..7760ba6`), 로컬 브랜치 삭제 완료

## Task 26 진행 상황 (`feature/global-accent-color`)
시트 안 강조색이 브랜드 색으로 바뀌지 않던 문제 수정(2026-09-09). Task 22 검증 중 발견해 승격했다.

### 구현 (커밋 1개)
- **강조색을 전역 빌드 설정으로 이동**(`26bf0de`) — `ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME: Main`. 중복이 된 `AppView`의 `.tint`는 제거했다

### `.tint`가 시트에 닿지 않는다
Task 20에서 `.tint`로 강조색을 맞췄을 때 **목록 화면만 보고 해결됐다고 판단했다.** `.tint`는 뷰 계층을 타고 내려가는데 시트는 별도 계층으로 올라온다. 온보딩 4페이지와 개념 카드가 전부 시트라, 그대로 뒀다면 Task 24 스크린샷에 시스템 파랑이 찍혔을 것이다.

`.tint`를 시트마다 다시 거는 방법도 있지만 **시트를 새로 만들 때마다 잊으면 되돌아간다.** 전역 강조색은 지정 지점이 하나이고 알럿까지 덮는다. 대신 지정 위치가 코드가 아니라 빌드 설정이라 눈에 띄지 않으므로 `project.yml`과 `AppView` 문서 주석 양쪽에 이유를 남겼다.

### 검증
- 픽셀 실측 — 시트 링크가 `#007AFF`에서 `#2563EB`로 바뀌었고, `.tint`를 뺀 뒤에도 탭 바는 `#2563EB`를 유지한다
- pbxproj는 Task 21과 같은 이유로 재생성하지 않았다. **xcodegen이 넣는 자리가 4개 블록 중 2개뿐이라 처음엔 4개 모두에 넣었다가 생성 결과와 대조해 2개로 줄였다** — 값이 같아도 배치가 다르면 나중에 재생성할 때 가짜 diff가 난다

## Task 26 완료 (`feature/global-accent-color`)
- 커밋 2개 — 설정·코드 1개(`26bf0de`)와 문서 1개(`ba9325b`)
- `develop`에 `--no-ff` 병합(병합 커밋 `2f7db5b`), 병합 직후 빌드 성공 재확인, `origin/develop` 푸시(`7760ba6..2f7db5b`), 로컬 브랜치 삭제 완료

## Task 23 진행 상황 (`feature/privacy-policy`)
개인정보처리방침·지원 페이지 원문과 앱 안 링크(2026-09-09). 배경은 `TODO.md` Task 23 절 참고.

### 결정이 두 번 바뀌었다
- **호스팅이 GitHub Pages에서 Notion으로 바뀌었다.** 사용자가 이미 다른 앱의 페이지를 Notion에 두고 있어 관리 지점이 모인다. 처음 GitHub Pages를 고른 근거였던 "추가 계정 불필요"는 이미 쓰는 도구 앞에서는 이점이 아니었다. HTML로 쓴 것을 마크다운으로 다시 썼다
- **지원 페이지가 범위에 추가됐다.** 착수 전 결정 목록에는 방침만 있었는데, `Support URL`도 심사 필수 항목이고 방침과 다른 주소여야 한다

### 구현 (커밋 4개)
- **방침 원문**(`60b97f2` → `c445bf2`) — 한국어·영어를 한 문서에 담았다. 파일을 나누면 심사자와 사용자가 서로 다른 주소를 보게 된다
- **설정 화면 링크**(`c103b39`) — 방침 전문을 앱에 넣지 않는다. 넣으면 방침이 바뀔 때마다 새로 심사받아야 하지만 웹 페이지는 고치면 바로 반영된다. 대신 푸터에 "수집하지 않는다"를 한 줄 두어 링크를 누르기 전에도 답이 보이게 했다
- **지원 페이지 원문**(`c445bf2`) — 자주 묻는 질문에 값 칸 더블 탭의 빨강 깜빡임을 넣었다. **사용자가 회귀로 의심했던 동작이라 다른 사람도 같은 질문을 한다**
- **App Store Connect 등록 정보**(`3b0e6ba`) — 이름·부제·설명·키워드를 한국어와 영어로, 스크린샷 계획과 제출 전 확인 목록까지

### 주소 형식에서 문제를 찾았다
사용자가 참고로 준 다른 앱의 방침 주소(`app.notion.com/p/...`)를 로그인 없이 가져와 보니 본문이 오지 않고 앱 껍데기만 왔다. `app.notion.com`은 로그인한 사용자의 작업 공간을 여는 주소이고, 공개 주소는 `notion.site` 형식이다. 심사자는 계정 없이 방침을 읽을 수 있어야 하며 열리지 않으면 그 사유만으로 반려된다.

**다만 "본문이 오지 않는다"를 로그인이 필요하다는 뜻으로 읽은 것은 성급했다.** 아래 페이지 실측에서 정정됐다 — Notion은 본문을 브라우저에서 그려서 채우므로, 자바스크립트를 실행하지 않는 요청에는 원래 껍데기만 온다.

### 페이지 실측 (2026-09-09)
사용자가 만든 두 페이지를 계정 없이 조회해 세 가지를 확인했다. 눈으로 열어 보는 대신 Notion의 공개 페이지 조회로 판별했다. **아래 셋 중 뒤의 두 건은 2026-09-10에 닫혔다** — 이 절은 그 시점의 기록이고 현재 상태는 "Notion 마무리 확인 (2026-09-10)" 절이 정본이다.

- **로그인 없이 읽힌다** — 페이지 정보에 `requireLogin: false`가 오고, 계정 없이 보낸 본문 요청에도 페이지가 그대로 왔다. 두 페이지 모두 삭제되지 않은 공개 상태다
- **본문이 비어 있다** — 두 페이지 다 제목 아래에 빈 문단 하나뿐이다. 저장소의 원문이 아직 붙여넣어지지 않았다
- **링크를 가진 사람이 편집할 수 있다** — 공개 권한이 `read_and_write`다. 주소를 아는 누구나 방침 문구를 고칠 수 있어 **읽기 허용으로 낮춰야 한다.** 심사 항목은 아니지만 방침 페이지에 열려 있어서는 안 되는 권한이다

### 주소 확정 후 반영
- `SettingView`의 상수를 `notion.site` 주소로 교체했다. 쓰지 않기로 한 GitHub Pages 주소가 남아 있어, 그대로 병합하면 존재하지 않는 주소가 앱에 들어갈 상태였다
- 사용자가 준 것은 `app.notion.com/p/...` 형식이라 **같은 페이지를 가리키는 `notion.site` 주소로 바꿔 넣었다.** 주소 끝 32자리 식별자가 같으면 같은 페이지다
- `docs/app-store-connect.md`의 미정 항목을 두 주소로 채우고, Notion 쪽에서 마무리할 항목 2건을 확인 목록에 남겼다

### 병합
- 커밋 9개를 `--no-ff`로 병합(병합 커밋 `5a5b498`), 병합 직후 빌드 성공 재확인, `origin/develop` 푸시(`2f7db5b..5a5b498`), 로컬 브랜치 삭제 완료
- **본문 붙여넣기와 공유 권한 낮추기는 Notion에서만 할 수 있어 병합을 막지 않았다.** 앱에 들어가는 주소는 페이지 내용과 무관하게 이미 확정됐다

## 문서 정리에서 발견한 것 (2026-09-09)
Task 23 병합 뒤 문서를 맞추다가 **Task 21·22·26이 병합돼 있는데 체크 항목은 열려 있는 것**을 발견했다. 세 Task 모두 병합·푸시까지 끝났지만 `TODO.md`의 `develop 병합` 줄과 백로그 항목이 닫히지 않아, 문서만 보면 아직 대기 중으로 보였다.

- 네 Task(21·22·26·23)의 병합 커밋을 한 커밋(`abedcb6`)으로 적었다
- **병합과 문서 반영 사이에 틈이 생기는 것이 원인이다.** 이전 Task들은 병합 직후 `docs: Task N 병합 완료 반영` 커밋을 `develop`에 바로 쌓았는데, 20번대에서 이 습관이 두 번 건너뛰어졌다

## Task 25 착수 전 조사 (2026-09-09)
내일 바로 시작할 수 있도록 런치스크린을 미리 조사해 `TODO.md` Task 25 절에 적었다. 결정이 필요한 것은 **배경색과 로고 여부 하나뿐이다.**

- `UILaunchScreen`은 색 자산·이미지 자산·안전 영역 여부만 받는다. **텍스트를 넣을 수 없어** 문구가 필요하면 스토리보드로 가야 하고 로컬라이즈 부담이 새로 붙는다
- 배경 후보 `Main`·`LightBlue` 둘 다 다크 변형이 있어 **색 자산 이름만 넣으면 두 모드가 함께 해결된다**
- 자산 카탈로그가 pbxproj에 폴더 하나로 등록돼 있어 **자산을 더해도 pbxproj를 건드리지 않는다.** `colorset`·`imageset` 참조가 0건임을 확인했다
- **iOS가 런치스크린을 캐시한다.** 시뮬레이터 확인에는 앱 삭제 후 재설치가 필요하다

## Notion 마무리 확인 (2026-09-10)
사용자가 두 페이지에 원문을 붙여넣고 공유 권한을 읽기 허용으로 바꿨다고 알려 와, 2026-09-09과 같은 방식으로 계정 없이 다시 조회해 대조했다. **열려 있던 항목 2건이 모두 닫혔고 Task 23이 완전히 끝났다.**

- **본문이 채워졌다** — 방침은 한국어 8절·English 8절, 지원은 자주 묻는 질문 5개를 포함해 양쪽 언어가 저장소 원문과 문장 단위로 일치한다. 헤더 단계도 원문의 `##`·`###`가 Notion의 제목 2·제목 3으로 그대로 옮겨졌다
- **공개 권한이 낮아졌다** — `read_and_write` → `reader`. 편집·댓글 가능 여부도 함께 꺼졌다
- **로그인은 여전히 필요 없다** — `requireLogin`이 `false` 그대로다. 권한을 낮추면서 공개 자체가 닫히지 않았다는 뜻이라 심사자 접근에 영향이 없다

### 눈으로 열어 보지 않고 판별한 이유
Notion은 본문을 브라우저에서 그려서 채우므로 주소를 그냥 가져오면 껍데기만 온다. 2026-09-09에 한 번 이것을 "로그인이 필요하다"로 잘못 읽었던 자리다. 이번에도 페이지 정보와 본문을 각각 계정 없이 조회해 **심사자와 같은 조건**에서 판별했다.

### 남은 다듬을 거리 (막지 않는다)
- 자주 묻는 질문에서 **굵은 질문과 답변이 한 문단으로 붙었다.** 원문은 질문 아래 줄에 답변을 뒀는데, Notion이 마크다운을 붙여넣을 때 문단 안의 줄바꿈을 합친다. 굵기는 살아 있어 읽는 데 지장은 없다. 질문 5개를 각각 두 문단으로 나누고 싶으면 Notion에서 답변 앞에 커서를 두고 줄을 나누면 된다

## Task 25 진행 상황 (`feature/launch-screen`)
런치스크린 지정(2026-09-10). 배경은 `TODO.md` Task 25 절 참고.

### 결정이 조사 중에 뒤집혔다
착수 전 조사(2026-09-09)는 배경 후보를 `Main`·`LightBlue` 두 브랜드 파랑으로 좁혀 뒀고, 물음은 "둘 중 무엇을 쓸 것인가 + 로고를 넣을 것인가"였다. **착수 시점에 전제 자체가 틀렸다는 것을 확인했다.**

- Human Interface Guidelines는 런치스크린을 **첫 화면과 거의 같게** 만들고 브랜딩 자리로 쓰지 말라고 권한다. 런치스크린은 보여주는 화면이 아니라 첫 화면이 준비되는 동안 자리를 지키는 빈 판이다
- 이 앱의 첫 화면은 `MainView`가 `systemGroupedBackground`를 배경에 건 레슨 목록이다. 파랑을 깔면 앱이 뜨는 순간 파랑에서 회백색으로 한 번 튄다
- **사용자에게 이 상충을 먼저 알리고 골랐다.** 원래 요청이 "처음 보이는 화면만 브랜딩과 무관하게 남아 있다"였으므로 브랜드 색을 넣는 선택도 그대로 후보에 뒀고, 사용자가 시스템 배경을 골랐다

### 값은 눈이 아니라 픽셀로 정했다
"시스템 배경"이 어떤 색인지 추측하지 않고 목록 화면을 라이트·다크로 촬영해 찍었다. **결과가 예상과 달랐다.**

- 첫 화면 배경은 라이트 `#F2F2F7` · 다크 `#000000`(`systemGroupedBackground`)
- 반면 빈 `UILaunchScreen`의 기본값은 `systemBackground`라 **라이트에서 순백 `#FFFFFF`**다. 흔히 같다고 넘기기 쉬운 두 색이 실제로는 다르다
- **다크는 원래 어긋나지 않았다.** 양쪽 다 검정이라 이번 변경으로 달라지는 것은 라이트뿐이다

### 구현 (커밋 2개)
- **색 자산 `LaunchBackground`**(`edc24af`) — `UILaunchScreen`은 색 자산 이름만 받고 시스템 색을 직접 가리킬 수 없어, 같은 값을 담은 자산을 새로 뒀다. 색 대응표에서는 `CodeKeyword`처럼 **별도 축**이다. 종류·상태·장식 어디에도 속하지 않고, 값은 브랜드가 아니라 첫 화면 배경을 따라간다
- **`UILaunchScreen` 지정**(`5777c80`) — `project.yml`과 `Info.plist` 두 곳을 손으로 맞췄다. 저장소 사본에서 xcodegen을 돌려 생성 결과와 **바이트 단위로 같은 것을 확인**했고, 자산 카탈로그가 pbxproj에 폴더로 등록돼 있어 `project.pbxproj`는 손대지 않았다

### 런치스크린을 붙잡아 두고 촬영했다
런치스크린은 순식간에 지나가 눈으로 판별할 수 없고, 연속 촬영으로도 어느 프레임이 런치스크린인지 확신하기 어렵다. **`simctl launch --wait-for-debugger`로 실행을 launch 시점에 붙잡으면 런치스크린만 화면에 남는다.**

- 변경 전 연속 촬영에서 `#FFFFFF` → `#F9F9FB` → `#F3F3F7` → `#F2F2F7` 순으로 흰색이 섞여 빠지는 것을 프레임 단위로 잡았다. 튀는 구간이 실재한다는 증거다
- 변경 후에는 라이트 `#F2F2F7` · 다크 `#000000`으로 첫 화면과 정확히 일치하고, `#F2F2F7`보다 밝은 프레임이 0개다
- **확인 전에 앱을 지우고 다시 설치했다.** iOS가 런치스크린을 스냅샷으로 캐시해 재설치 없이는 이전 화면이 계속 나온다

### 병합
- 사용자가 앱을 지우고 다시 설치해 확인했고 보고된 문제가 없다
- 커밋 5개(코드 2 + 문서 3)를 `--no-ff`로 병합(병합 커밋 `57a8bad`), 병합 직후 빌드 성공 재확인, `origin/develop` 푸시(`c6e1615..57a8bad`), 로컬 브랜치 삭제 완료
- **밀려 있던 Notion 문서 커밋 2개(`4d8083d`·`abe8880`)도 이 푸시에 함께 올라갔다.** Task 23 마무리를 `develop`에 바로 쌓아 두고 푸시는 하지 않은 상태였다

## Task 24 착수와 중단 (`feature/app-store-metadata`)
스크린샷·메타데이터(2026-09-10). 커밋 2개를 쌓은 뒤 Task 27을 발견해 멈췄다.

### 규격을 실측으로 두 번 정정했다
문서에 적어 둔 값을 그대로 믿지 않고 찍어서 확인했고, **두 항목이 틀려 있었다.**

- **크기** — `1290 x 2796`으로 적혀 있었으나 그것은 6.7인치(iPhone 15 Pro Max) 값이다. 실제 6.9인치는 `1320 x 2868`이다. Apple 문서에서 6.9인치 자리가 `1260 x 2736`·`1290 x 2796`·`1320 x 2868` 셋을 받는 것도 확인했고, 축소하면 글자가 뭉개지므로 기기 해상도 그대로인 값을 쓴다
- **알파 채널** — App Store Connect는 알파가 있는 이미지를 거부하는데 `simctl io screenshot`은 RGBA로 내보낸다. 그대로 올리면 업로드에서 막힌다. 전 픽셀이 불투명이라 채널만 떼어내면 색이 달라지지 않는다

### iOS 버전을 사용자가 짚어 다시 찍기로 했다
처음에는 iPhone 16 Pro Max(iOS 18.5)로 찍었는데, **사용자가 "iOS 26이 아닌데 괜찮은가"를 물어 확인해 보니 문제가 있었다.**

- App Store Connect는 픽셀 크기만 검사하므로 iOS 18로 찍어도 반려되지는 않는다
- **그러나 이 앱은 Xcode 26.6의 iOS 26.5 SDK로 빌드된다.** iOS 26 기기에서는 탭 바가 떠 있는 캡슐로 바뀌는 등 시스템 외형이 달라져, iOS 18 스크린샷은 실제 사용자가 보는 화면과 다르다
- iPhone 17 Pro Max(iOS 26.5)도 `1320 x 2868`로 크기가 같아 **규격을 바꾸지 않고 기기만 옮기면 됐다**

### 촬영 방법
시뮬레이터 조작은 사용자가 하고 촬영만 자동화했다. 화면마다 신호를 주고받으면 왕복이 많아지므로, **연속 촬영을 걸어 두고 그동안 사용자가 둘러보는 방식**을 썼다. 2초 간격으로 찍은 뒤 프레임을 해시로 묶어 정지 화면만 골라냈다.

- 상태 표시줄은 `simctl status_bar override`로 `9:41`·배터리 100%·신호 최대에 고정했다. 실제 시각과 배터리가 찍히면 벌마다 달라진다
- 언어는 `simctl launch ... -AppleLanguages "(en)"` 실행 인자로 바꿨다. 기기 언어 설정을 건드리지 않는다
- 온보딩 시트는 앱 컨테이너 plist의 `isOnboardingWatched`로 미리 닫아 뒀다

### 완료한 것
- **수출 규정**(`2190518`) — `ITSAppUsesNonExemptEncryption`을 `false`로 넣어 업로드마다 되묻지 않게 했다. 빌드 산출물의 `Info.plist`에 값이 들어간 것까지 확인했다
- **규격 정정과 촬영 조건 기록**(`6bbb389`) — [docs/app-store-connect.md](./docs/app-store-connect.md)

### 왜 멈췄나
한국어 후보 컷을 고르다 **플레이그라운드 화면의 코드 패널에서 컴파일되지 않는 C를 발견했다.** 스크린샷을 먼저 끝내면 고친 뒤 다시 찍어야 하고 사용자가 시뮬레이터를 두 번 조작하게 되므로, 버그를 Task 27로 먼저 닫기로 했다.

## Task 27 진행 상황 (`feature/sandbox-variable-names`)
코드 패널의 잘못된 C 표기(2026-09-10). 배경과 상세는 `TODO.md` Task 27 절 참고.

### 스크린샷을 찍지 않았으면 제출까지 갔을 문제다
Task 19가 "영어로 한 번 써 본 것"에서 나왔듯, 이번 둘은 **후보 컷을 눈으로 훑는 과정에서 나왔다.** 둘 다 평소 플레이에서는 잘 보이지 않는 경로다.

- 이름 겹침은 플레이그라운드에서 포인터를 **이어서** 연결해야 나온다
- 체인 타입 오류는 레슨 3에서 **세 칸을 다 이은 뒤 맨 앞 칸을 탭해야** 나온다

### 두 문제의 뿌리가 같다
둘 다 "코드 패널이 실제 상태를 표현하지 못하고 고정된 틀에 끼워 맞췄다"는 것이다.

- 이름 — 포인터는 번호를 붙여 구분했는데 값은 `"target"` 하나로 고정했다
- 타입 — 별 개수를 `int *`·`int **`로 고정해 두 칸짜리 체인만 표현할 수 있었다

고친 방식도 같다. **고정값을 실제 상태에서 계산한다.** 이름은 이미 쓰인 것을 피해서 번호를 붙이고, 별 개수는 체인을 따라가 센다.

### 구현 (커밋 3개)
- **이름 겹침 방지**(`bb5c357`) — `uniqueName`으로 `target`·`target2`를 나눈다. `makePointerName()`도 쓰이는 번호를 건너뛴다
- **체인 깊이 계산**(`fc4149c`) — `pointerDepth`가 체인을 따라가며 별 개수를 센다. 주소 리터럴 대신 대상 이름을 쓴다. 순환 연결에서 멈추도록 지나온 칸을 기억한다
- **영어 번역 교체**(`80a47e0`) — 옛 키 1개 삭제, 새 키 2개 추가

### 회귀 확인
수정한 빌드로 다시 찍은 프레임에서 **레슨 1·3의 라벨이 그대로인 것을 대조했다.**

- 레슨 1 — `target`·`p1`. 이름을 선언하지 않는 레슨이라 fallback을 타는데 겹칠 상대가 없어 그대로다
- 레슨 3 — `start`·`nodeA`·`nodeB`·`treasure`. `SlotSeed.variableName`으로 직접 선언해 원래 안전했다
- 플레이그라운드 — `target`·`target2`로 갈리고 코드 패널이 유효한 C가 됐다. 사용자가 스크린샷으로 확인해 줬다

### Task 27이 후속 하나를 만들었다
수정 결과 레슨 3에 `int ***`가 나온다. 타입은 정확하지만 레슨이 설명하지 않는 표기라 **사용자 판단으로 고치기로 하고 Task 28로 등록했다.**

- **빠진 것은 규칙이 아니라 규칙과 화면을 잇는 한 문장이다.** 레슨 2 개념 카드가 이미 "`*`가 하나 늘어날 때마다 값에 닿기까지 한 번 더 따라가야 합니다"라고 규칙을 가르친다. 레슨 3 개념 카드는 네 문장이 전부 경로와 연결 리스트 이야기라 타입을 한 번도 언급하지 않는다
- 유력안은 레슨 3 개념 카드에 문장 하나를 더하는 것이다. 코드 변경이 없고 신규 로컬라이즈 키 1개로 끝난다
- **깊이를 낮춰 표시하는 것은 후보가 아니다.** 타입이 다시 틀려져 Task 27에서 고친 문제로 되돌아간다
- **스크린샷을 막지 않는다.** 개념 카드 컷은 레슨 1의 것을 쓰고, 코드 패널 출력도 바뀌지 않는다

## 다음 작업
- **Task 27 사용자 검증 대기** — 레슨 3에서 `int **nodeA`·`int ***start`가 나오는지, 레슨 1·2가 그대로인지, 영어에서 문구가 한국어로 남지 않는지 확인한 뒤 병합한다
- **Task 28은 착수 전이다** — 1.0에 넣을지 먼저 정한다. 비용이 문장 하나와 번역 하나라 포함을 권한다
- **그다음 Task 24 재개** — `feature/app-store-metadata`에 `develop`을 병합해 넣고 다시 빌드한 뒤 한국어·영어를 한 번에 찍는다. **레슨 3 컷은 코드가 바뀌었으므로 다시 찍는다**
- 한국어 후보 5장(목록·개념 카드·레슨 1 연결·플레이그라운드·완료 알럿)은 Task 27의 영향을 받지 않아 그대로 쓴다
