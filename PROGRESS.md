# PROGRESS

세부 작업 항목은 [TODO.md](./TODO.md), 전체 방향은 [PLAN.md](./PLAN.md) 참고.

## 현재 상태

- `feature/lesson-data-model` (Task 1), `feature/blueprint-driven-vm` (Task 2), `feature/learning-tone-copy` (Task 3) 모두 `develop`에 병합 완료 (병합 커밋 `42efd7b`, `37ba5ce`), `origin/develop`에 푸시 완료
- `feature/learning-tone-copy` 로컬 브랜치는 병합 후 삭제 완료
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

## 다음 작업

- `feature/sandbox-mode` (Task 4) 브랜치 생성 완료, `develop`에서 분기. 아직 구현은 시작 전 — 다음 세션에서 이어서 착수
- Task 4 착수 시 먼저 확인할 것 (Task 3 로컬라이제이션 후속 검증, `TODO.md` 참고)
  - Xcode 클린 빌드 후 `Localizable.xcstrings`의 `STALE` 배지 해소 여부 확인
  - 시뮬레이터가 영어로 표시되는 원인 점검 (Xcode 스킴 App Language 고정 여부, 앱 재설치 후 최초 실행 로직 재현 여부)
- Task 4 본 작업: `MemoryGridVM` sandbox 초기화 경로, `MemoryGridView` sandbox UI 분기, Main 화면 Playground 진입점 카드 (`TODO.md` 체크리스트 참고)
