# PROGRESS

세부 작업 항목은 [TODO.md](./TODO.md), 전체 방향은 [PLAN.md](./PLAN.md) 참고.

## 현재 상태

- `feature/lesson-data-model` (Task 1), `feature/blueprint-driven-vm` (Task 2) 모두 `develop`에 병합 완료 (병합 커밋 `42efd7b`)
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

## 진행 중 — Task 3 (`feature/learning-tone-copy`)

게임 카피 → 학습 도구 카피 전환 + 로컬라이제이션(한국어 기본/영어 선택) 도입. 범위와 세부 계획은 `TODO.md`/`PLAN.md` 참고.

- [x] `Core/Lesson.swift`의 `initialCodeLog` "Level 1/2/3" → "Lesson 1/2/3" 텍스트 수정
- [x] `TODO.md`/`PLAN.md`에 로컬라이제이션 범위(String Catalog, `LocalizedStringResource` 전환, 최초 실행 한국어 기본값, 설정 화면 언어 선택 UI) 반영
- [x] `MemoryGridVM.swift`의 잠금/에러/완료 `codeLog` 문구를 설명형 학습 톤으로 변경 ("Access Denied"/"Security Violation"/"Level Clear!" 제거)
- [x] `MissionHeaderView.swift` → `LessonHeaderView.swift` 리네임 (파일명·구조체명·"Mission"→"Lesson" 라벨), `MemoryGridView.swift`의 참조 갱신
- [x] `MemoryGridView.swift`의 alert 타이틀 "Mission Complete! 🎉" → "Lesson Complete! 🎉"
- [x] `LessonCard.swift`의 "Lv. N"/"LEVEL N" → "Lesson N"
- [x] `OnboardingView.swift`의 "Level" 잔존 표현 → "Lesson" 통일
- [x] `Localizable.xcstrings` String Catalog를 프로젝트에 추가 (`project.pbxproj` 수동 편집 — 파일 참조 + Resources 빌드 페이즈 + `knownRegions`에 `ko` 추가, 빈 카탈로그 상태로 빌드 검증 완료)
- [ ] `Lesson`/`Chapter`의 `title`/`description`을 `LocalizedStringResource`로 전환
- [ ] `Localizable.xcstrings`에 앱 전체 문구 `ko` 번역 채우기
- [ ] 앱 최초 실행 시 한국어 기본값 강제 로직 추가
- [ ] `SettingView`에 언어 선택(한국어/English) UI + 재시작 안내 추가

## 다음 작업

- Task 3 완료 후 `develop`에 병합, Task 4(`feature/sandbox-mode`) 브랜치 착수 예정
