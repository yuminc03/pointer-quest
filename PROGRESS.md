# PROGRESS
세부 작업 항목은 [TODO.md](./TODO.md), 전체 방향은 [PLAN.md](./PLAN.md) 참고.

## 현재 상태 (2026-09-02 기준)
- Task 1~12 모두 구현·사용자 검증·`develop` 병합 완료 (최신 병합 커밋 `efe3119`)
- Task 13(언어 변경 방식 개선)까지 구현·실기기 검증·`develop` 병합 완료
- 병합 완료된 로컬 feature 브랜치는 매번 삭제 완료
- 다음 착수 항목은 1.0 순서 2번 "브랜딩·비주얼 언어 확정" (`PLAN.md` 백로그 C)
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

## 다음 작업
- `PLAN.md`의 "1.0 (출시 전)" 2번 항목 **브랜딩·비주얼 언어 확정**(백로그 C) 착수 예정 — 앱 이름/부제/아이콘/색 팔레트와, 학습 효과 보강(B-2/B-1)의 선행 조건인 **도식 표기 규칙**까지 확정한다. 착수 시 별도 Task로 승격
  - 학습 효과 보강 — B-2(레슨 0 "변수와 메모리")부터 착수. 별도 Task로 승격 시 세부 실행 계획 확정 필요
  - 언어 변경 방식 개선
  - 앱 이름/브랜딩/아이콘 재검토
  - App Store 심사 대비 항목 점검
