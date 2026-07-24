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
- [x] (Task 3 후속) Xcode에서 클린 빌드 후 `Localizable.xcstrings`의 `STALE` 배지가 해소되는지 확인 (`SWIFT_EMIT_LOC_STRINGS` 반영에는 재컴파일이 필요해 증분 빌드만으로는 남아있을 수 있음)
- [x] (Task 3 후속) 시뮬레이터에서 앱이 영어로 표시되는 원인 점검: Xcode 스킴의 Run > Options > App Language가 "System Language"가 아닌 값으로 고정돼 있는지, 이미 설치된 앱이라 최초 실행 로직이 재실행되지 않는지(삭제 후 재설치로 재현) 확인
- [x] Playground 화면 수동 드래그 테스트 (포인터 연결/해제/리셋, "Lesson Complete" 알림 미표시) 확인

## Task 5 — `feature/lesson-progress-tracking`

레슨 완료 진행 상황 저장 및 카드 체크마크 표시

- [x] 완료 레슨 id `UserDefaults` 저장
- [x] `LessonCard` 체크마크 표시

## Task 6 — `feature/chapter-placeholders`

Chapter 2~5 placeholder 등록 (Coming Soon UI)

- [x] Chapter 2~5 데이터 등록
- [x] Coming Soon 카드 UI

## Task 7 — `feature/card-paging-redesign`

Main 화면 카드 페이징 UI 개선 (Apple HIG 준수 + 반응형 대응)

- [x] `PagingCardsScrollView`/`LessonCard` 레이아웃을 Apple Human Interface Guidelines 기준(여백, 타이포그래피, 터치 타겟 크기 등)으로 재검토 → 조사 결과 가로 캐러셀 자체가 계층적 콘텐츠에 부적합하다고 판단, 챕터별 `Section`을 가진 세로 `List`(insetGrouped)로 전면 재설계
- [x] iPhone SE~Pro Max 등 다양한 화면 크기에서 카드가 잘리거나 깨지지 않도록 반응형 처리 (현재 `screenWidth - 100`, `cardWidth / 2.5 * 3.5` 등 특정 화면 크기를 가정한 하드코딩 치수 점검) → 커스텀 치수 계산을 제거하고 시스템 `List`에 위임해 모든 화면 크기에서 자동 대응 (iPhone 17에서 사용자 검증 완료)

## Task 8 — `feature/localization-source-swap`

로컬라이제이션 소스 언어를 한국어로 전환

- [ ] 앱 전체 `Text()`/`Lesson`·`Chapter`의 `title`/`description` 등 사용자 노출 문구의 코드 리터럴을 한국어로 전환
- [ ] 기존 영어 문구를 `Localizable.xcstrings`의 `en` 로컬라이제이션으로 이관 (영어 사용자에게 보이는 내용은 동일하게 유지)

## 백로그

- [ ] Chapter 2~5 실제 레슨 콘텐츠 저작
- [ ] 앱 이름/브랜딩/아이콘 재검토
- [ ] App Store 심사 대비 항목 점검 (개인정보처리방침, 스크린샷, 지원 언어 등)
