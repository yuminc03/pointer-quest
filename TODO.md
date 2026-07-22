# TODO

작업 순서와 브랜치 전략은 [PLAN.md](./PLAN.md)를 따른다. Task마다 `develop`에서 새 feature 브랜치를 파고, 완료 후 병합 여부를 확인한 뒤 다음 Task 브랜치를 새로 판다.

## Task 1 — `feature/lesson-data-model`

`Lesson`/`LessonBlueprint`/`SuccessCondition`/`Chapter` 데이터 모델 정의 (기존 3레벨 데이터를 새 구조로 마이그레이션)

- [x] `Level.swift` → `Lesson.swift` 리네임 및 타입명 변경 (`Level` → `Lesson`, `LevelData` → `LessonData`, `LevelCard` → `LessonCard`)
- [x] `LessonBlueprint`/`SlotSeed`/`SuccessCondition` 타입 추가
- [x] `Chapter` 타입 추가 및 기존 3레벨을 Chapter 1로 마이그레이션

## Task 2 — `feature/blueprint-driven-vm`

`MemoryGridVM`을 블루프린트 기반 범용 로직으로 리팩터링 (기존 3레벨 동작 동일성 확인)

- [x] 블루프린트 기반 `setupLevel` 교체
- [x] 블루프린트 기반 `checkSuccess` 교체 및 기존 switch 제거

## Task 3 — `feature/learning-tone-copy`

게임 카피 → 학습 도구 카피 전환 + 로컬라이제이션(한국어 기본/영어 선택) 도입

- [x] "Mission" → "Lesson" 등 문구 조정 (`MissionHeaderView` → `LessonHeaderView` 컴포넌트명 포함)
- [x] "Level Clear! 🎉" → "Lesson Complete! 🎉" 학습 완료 문구로 변경
- [x] 에러/잠금 문구를 설명형으로 다듬기
- [x] "Lv. N" 등 게임 용어를 "Lesson N"으로 조정
- [x] `Localizable.xcstrings` String Catalog 도입 (소스 `en`, 번역 `ko`), `project.pbxproj`의 `knownRegions`에 `ko` 추가
- [x] `Lesson`/`Chapter`의 `title`/`description`을 `LocalizedStringResource`로 전환하여 데이터 기반 문구도 로컬라이즈되도록 처리 (`codeLog`는 C 코드 관례상 영어로 고정, 로컬라이즈 제외)
- [x] 앱 최초 실행 시 한국어를 기본값으로 강제 적용하는 로직 추가
- [x] `SettingView`에 언어 선택(한국어/English) UI 및 재시작 안내 추가

## Task 4 — `feature/sandbox-mode`

샌드박스 모드 추가

- [x] `MemoryGridVM` sandbox 초기화 경로 추가
- [x] `MemoryGridView` sandbox UI 분기
- [x] Main 화면 Playground 진입점 카드 추가
- [ ] (Task 3 후속) Xcode에서 클린 빌드 후 `Localizable.xcstrings`의 `STALE` 배지가 해소되는지 확인 (`SWIFT_EMIT_LOC_STRINGS` 반영에는 재컴파일이 필요해 증분 빌드만으로는 남아있을 수 있음)
- [ ] (Task 3 후속) 시뮬레이터에서 앱이 영어로 표시되는 원인 점검: Xcode 스킴의 Run > Options > App Language가 "System Language"가 아닌 값으로 고정돼 있는지, 이미 설치된 앱이라 최초 실행 로직이 재실행되지 않는지(삭제 후 재설치로 재현) 확인

## Task 5 — `feature/lesson-progress-tracking`

레슨 완료 진행 상황 저장 및 카드 체크마크 표시

- [ ] 완료 레슨 id `UserDefaults` 저장
- [ ] `LessonCard` 체크마크 표시

## Task 6 — `feature/chapter-placeholders`

Chapter 2~5 placeholder 등록 (Coming Soon UI)

- [ ] Chapter 2~5 데이터 등록
- [ ] Coming Soon 카드 UI

## 백로그

- [ ] Chapter 2~5 실제 레슨 콘텐츠 저작
- [ ] 앱 이름/브랜딩/아이콘 재검토
- [ ] App Store 심사 대비 항목 점검 (개인정보처리방침, 스크린샷, 지원 언어 등)
