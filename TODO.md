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
- [x] `Lesson`/`Chapter`의 `title`/`description`을 `LocalizedStringResource`로 전환하여 데이터 기반 문구도 로컬라이즈되도록 처리 (`codeLog`는 이 시점엔 C 코드 관례상 영어로 고정, 로컬라이즈 제외 — 이후 Task 8 후속에서 재검토되어 로컬라이즈 대상으로 전환됨)
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

- [x] 앱 전체 `Text()`/`Lesson`·`Chapter`의 `title`/`description` 등 사용자 노출 문구의 코드 리터럴을 한국어로 전환
- [x] 기존 영어 문구를 `Localizable.xcstrings`의 `en` 로컬라이제이션으로 이관 (영어 사용자에게 보이는 내용은 동일하게 유지) — `sourceLanguage`(`ko`)와 `project.pbxproj`의 `developmentRegion`(`ko`)도 함께 전환
- [x] `codeLog`(하단 C 코드 로그 영역)를 실제 로컬라이즈 대상으로 전환 — `String` → `LocalizedStringResource`로 타입 변경, `//` 주석은 한국어 소스로 작성하고 `Localizable.xcstrings`에 `en` 번역 추가 (`int`/`printf` 등 C 코드 구문 자체는 두 언어 공통으로 영어 유지)

## Task 9 — `feature/lesson-grid-ux-improvements`

2026-07-29 사용자 UX 리뷰(처음 써보는 사람 시점) 반영. 계획 상세는 `/Users/chuyumin/.claude/plans/i-m-concerned-about-whether-hashed-pinwheel.md` 참고.

- [x] Task A: 코드 패널(`CodeFeedbackView`) 개편 — `codeLog` 마크다운 오인식 버그 수정(`String(localized:)` 리졸브 후 `CCodeHighlighter`로 직접 채색해 `Text`의 마크다운 파싱 경로 우회) + C 키워드/문자열/주석 문법 강조 + 여러 줄 표시 레이아웃 개선. `CCodeHighlighter.swift` 신설·`CodeFeedbackView.swift` 수정·`project.pbxproj` 등록까지 완료, `xcodebuild` 빌드 성공 확인 — 시뮬레이터 수동 검증(마크다운 버그 재현 안 됨, 문법 강조 정상 표시) 완료
- [x] Task B: 그리드 화면(`MemoryGridView`) 내 실사용 맥락 힌트 오버레이 추가 — 기존 Welcome 시트/정적 이미지 튜토리얼(`OnboardingView`)은 유지하되, 레슨 1 최초 진입 시 실제 그리드 위에 드래그 방법을 보여주는 힌트를 1회 노출. `GridInteractionHintOverlay.swift` 신설(소스→타겟 손동작 애니메이션 + 안내 말풍선), `MemoryGridView`에 `@AppStorage("hasSeenGridHint")`로 앱 전체 최초 1회 노출 연동. 소스 슬롯(index 8)의 `pointingTo`가 바뀌는 순간(첫 드래그 완료) 자동 해제 + 닫기 버튼으로 즉시 해제 가능, `MemoryGridVM`에는 힌트 로직 미포함. `project.pbxproj` 등록 완료, 빌드 가능한 최소 단위 2개 커밋(`5603171`, `f2c88ec`)으로 분리해 매 커밋 빌드 확인, 사용자 시뮬레이터 검증 완료
- [x] Task C: 레슨 2 "Lock" 메커닉 제거 — 실제 C에는 없는 "잠긴 메모리" 개념이 빨간 흔들림 에러와 결합돼 오답처럼 느껴지는 문제의 근본 원인이라 판단, 논블로킹 힌트("이미 있는 포인터를 가리켜보세요") + "힌트 보기" 버튼으로 전환. 자기참조 포인터/잘못된 역참조 에러는 실제 C 오류이므로 그대로 유지. 구현 완료(5개 커밋, 매 커밋 빌드 확인), 사용자가 시뮬레이터에서 테스트 항목 6개(참조 배지, 직접 연결 허용, 안내 문구, 정상 클리어, 힌트 보기 버튼, 회귀) 모두 정상 확인 완료
- [x] Task D: 레슨 1 포인터 슬롯에 "주소 vs 값" 구분 보강 — 대상 주소 앞에 화살표 접두어(`→`) 표시 + `codeLog` 설명 문구에 "포인터 자신도 메모리에 저장된 값(주소)"이라는 점을 한 줄 추가해, 화살표 애니메이션 하나에만 의존하지 않도록 함. `MemoryItem.swift`/`MemoryGridVM.swift` 수정 완료(커밋 `aae8bce`, `93af209`), 빌드 성공 확인. 사용자가 시뮬레이터에서 직접 검증 완료

## Task 10 — `feature/reference-badge-visibility`

레슨 2 참조 배지(`link` 아이콘) 가시성 개선. Task 9 Task C 사용자 검증(2026-08-05) 도중 발견된 후속 항목.

- [x] `MemoryItem.swift`의 참조 배지(`link` SF Symbol) 크기/스타일 개선 — 카드 배경색(빨강/노랑/기본 회색)과 무관하게 눈에 띄도록 색이 채워진 원형 배지 형태로 변경. 구현 완료(커밋 `1924fe4`), 빌드 성공 확인. 사용자가 시뮬레이터에서 직접 검증 완료(배지 표시, 에러/하이라이트 배경 위 대비, 다른 콘텐츠와 겹침 없음, 접근성 라벨, 레슨 1·3/샌드박스 회귀 없음 등 6개 항목 모두 정상)

## Task 11 — `feature/grid-variable-labels`

그리드 블록에 코드 패널(`CodeFeedbackView`)에서 쓰이는 변수명(예: `p`, `target`) 함께 표시. 2026-07-30 제안된 백로그 항목을 Task 10 병합 완료 후 다음 착수 항목으로 승격.

- [x] `MemorySlot`에 `variableName: String?` 필드 추가 (커밋 `7a48e74`)
- [x] `MemoryGridVM`의 각 인터랙션(`handleTap`/`handleDrop`/`dereference`)에서 `codeLog`에 등장하는 변수명을 해당 슬롯에 부여 — 슬롯에 이미 이름이 있으면 덮어쓰지 않고 유지(누적 방식으로 그리드 전체가 "주소 ↔ 변수명 지도"처럼 채워지도록 함), 레슨 리셋 시에는 `setupLevel`이 슬롯을 새로 생성하므로 자연히 초기화됨 (커밋 `96efc79`)
- [x] `MemoryItem`에 변수명 라벨 표시 (커밋 `c243b7f`)
- [x] (1차 사용자 검증 후속) 레슨 3(체인 연결)에서 여러 포인터 슬롯이 전부 `p`로 겹쳐 표시되는 문제 수정 — `SlotSeed.variableName`으로 레슨이 직접 의미 있는 이름(`start`/`nodeA`/`nodeB`/`treasure`)을 선언할 수 있게 하고, 선언이 없는 슬롯은 `p1`/`p2`/`p3`처럼 번호로 자동 구분. `codeLog` 텍스트도 항상 실제 부여된 이름을 쓰도록 통일해 코드 문구와 그리드 라벨 불일치도 함께 해소 (커밋 `188f464`, `9b87535`)
- [x] (2차 사용자 검증 후속) `handleDrop`의 일반 연결 분기가 목적지 슬롯 이름을 정하지 않고 주소 리터럴을 그대로 코드에 넣던 문제 수정 — 연결 시점에 목적지 이름도 함께 확정하고 `int *p = 0x702C;` 대신 `int *p = &destName;` 형태로 표시 (커밋 `1cca04d`). 사용자가 시뮬레이터에서 직접 검증 완료(레슨 3 연결 코드가 이름으로 표시, 레슨 1 라벨 일관성, 리셋 시 `p1`부터 재시작 등 정상 확인)

## Task 12 — `feature/swiftui-style-cleanup`

SwiftUI 코드를 사용자 코딩 스타일에 맞게 정리. 백로그 항목을 Task 11 병합 완료 후 다음 착수 항목으로 승격.

- [x] 기준 확인 — 리포에 스타일 가이드 문서나 린터 설정(`.swiftlint.yml`/`.swift-format`)이 없음을 확인하고, git tag `1.0`(`a85ba75`, 사용자가 직접 작성한 원본) 전체 소스에서 실제 반복되는 관례를 추출
- [x] `STYLE_GUIDE.md` 신설 — 추출한 규칙 11개 항목(포매팅, 문서 주석, 선언 순서, 서브뷰 분리, 뷰 본문 여백, 인자 줄바꿈, guard, 모델 타입, 색상/이미지, 프리뷰, 로컬라이제이션)을 문서화
- [x] Task 1~11에서 Claude가 신설하거나 대폭 수정한 파일을 가이드 기준으로 정리 (전체 25개 파일 일괄 정리는 회귀 부담이 커 이번 범위에서 제외) — 대상 9개 파일 중 실제 이탈이 있던 5개 파일을 6개 커밋으로 정리(`cdf0c29`, `aedfea5`, `c2f1cfb`, `f049201`, `0af91d0`, `0f2d33a`), 나머지 4개(`LessonProgressStore`/`CCodeHighlighter`/`MemoryItem`/`ArrowDrawLayer`)는 대조 결과 이탈이 없어 무수정. 사용자 시뮬레이터 검증 완료
- [x] (작업 중 발견) 실측 결과 가이드 자체가 원본과 어긋난 규칙 4건을 정정 — guard 줄바꿈, `#Preview` 예외, 줄 끝 공백, View 프로퍼티 선언 순서 (`7ad90d5`, `be9a073`, `74aa686`)

## 백로그

2026-08-14 기준으로 1.0 출시 전 항목과 출시 후 업데이트 항목을 구분했다. 상세 배경·방향은 [PLAN.md](./PLAN.md)의 "출시 로드맵" 참고.

### 1.0 (출시 전)

- [ ] 언어 변경 방식 개선 — 앱 내 언어 선택 목록을 없애고, 현재 적용된 언어만 표시한 뒤 탭하면 iOS 설정 앱의 앱별 언어 설정으로 이동시킨다. 시스템 설정에서 언어를 바꾸면 iOS가 앱을 종료시키므로 돌아왔을 때 자동으로 새 언어가 적용되어, 기존의 "재시작해주세요" 알럿이 불필요해진다 (상세는 `PLAN.md`의 "백로그 A")
- [ ] 앱 이름/브랜딩/아이콘 재검토
- [ ] App Store 심사 대비 항목 점검 (개인정보처리방침, 스크린샷, 지원 언어 등)

### 1.x (출시 후 업데이트)

- [ ] Chapter 2~5 실제 레슨 콘텐츠 저작 — 분량이 가장 크고 출시를 막을 이유가 없어 1.0 이후 업데이트로 분리. 남은 백로그 중 **가장 마지막** 순서로 진행
