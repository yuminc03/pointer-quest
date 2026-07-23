# PROGRESS

세부 작업 항목은 [TODO.md](./TODO.md), 전체 방향은 [PLAN.md](./PLAN.md) 참고.

## 현재 상태

- `feature/lesson-data-model` (Task 1), `feature/blueprint-driven-vm` (Task 2), `feature/learning-tone-copy` (Task 3), `feature/sandbox-mode` (Task 4) 모두 `develop`에 병합 완료 (병합 커밋 `42efd7b`, `37ba5ce`, `41d01af`), `origin/develop`에 푸시 완료
- 병합 완료된 로컬 feature 브랜치는 매번 삭제 완료
- 현재 `develop`에서 분기한 `feature/lesson-progress-tracking` (Task 5) 브랜치에서 작업 중
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

## 다음 작업

- Task 5(`feature/lesson-progress-tracking`)를 `develop`에 병합
- Task 6(`feature/chapter-placeholders`)으로 진행: Chapter 2~5 placeholder 등록 (Coming Soon UI)
