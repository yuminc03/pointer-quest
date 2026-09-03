# TODO
작업 순서와 브랜치 전략은 [PLAN.md](./PLAN.md)를 따른다. Task마다 `develop`에서 새 feature 브랜치를 파고, 완료 후 병합 여부를 확인한 뒤 다음 Task 브랜치를 새로 판다.

## 다음 단계 (2026-09-03 기준)
작업을 다시 이어받을 때 이 절부터 읽는다. 세부 내용은 각 Task 절과 [PLAN.md](./PLAN.md)를 참고한다.

- **현재 위치** — Task 15(B-2 레슨 0 "변수와 메모리") 구현 및 사용자 시뮬레이터 검증 완료. `feature/lesson-zero-variables` 브랜치에서 **커밋·병합 대기 중**
- **바로 다음** — `develop`에 `--no-ff` 병합 → 학습 효과 보강 **B-1(레슨별 개념 카드)**
- **그 다음** — B-4(레슨 마무리 요약) → 1.0 4번(App Store 심사 대비: 개인정보처리방침, 스크린샷, 지원 언어, **앱 아이콘**)
- **미뤄둔 수정** — Task 14 실측에서 나온 이탈 6건. 아래 "Task 14에서 발견한 이탈" 절과 [VISUAL_LANGUAGE.md](./VISUAL_LANGUAGE.md) §7에 목록으로만 남겨 두었다. 지금은 고치지 않으며, 별도 Task로 승격할 시점을 따로 정한다

### B-2 착수 전 확인 사항 (Task 15 착수 시 판단 완료)
실측으로 미리 확인해 둔 항목이며, 2026-09-03 착수 시점에 사용자 결정으로 셋 다 마무리했다.

- **레슨 id 0이 이미 점유돼 있다** — `LessonData.sandboxLesson`이 `id: 0`을 썼다. **결정: 샌드박스 id를 챕터 밖 예약 번호대인 `100`으로 옮기고 레슨 0이 id 0을 갖는다.** `UserDefaults` 충돌은 없다 — 샌드박스의 성공 조건은 `.sandbox`이고 `checkSuccess`가 이 케이스에서 `break`하므로 `finishLevel()`이 호출된 적이 없어 완료 id에 `0`이 저장될 수 없었다. 실제 제약은 저장소가 아니라 `Lesson`이 `id` 기준 `Hashable`이고 `MainView`가 값 기반 내비게이션을 쓴다는 점이었다
- **성공 조건에 맞는 케이스가 없다** — **결정: 새 케이스 `.inspectedAll(indices:)`를 추가한다.** 지정된 슬롯을 모두 탭해 확인하면 클리어되며, 연결이 아니라 관찰이 목표인 레슨을 표현한다. `.sandbox` 재사용은 클리어 판정이 없어 완료 체크마크가 붙지 않으므로 채택하지 않았다
- **재사용할 자산** — `SlotSeed.variableName`(Task 11)으로 세 상자에 `age`/`score`/`level` 이름을 직접 선언했다. 도식은 [VISUAL_LANGUAGE.md](./VISUAL_LANGUAGE.md) §2의 값 슬롯 표기를 그대로 쓰고 새 모양을 만들지 않았다

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

## Task 13 — `feature/app-language-settings-link`
언어 변경 방식 개선. 1.0 착수 순서 1번 항목을 백로그에서 Task로 승격. 상세 배경·방향은 [PLAN.md](./PLAN.md)의 "백로그 A" 참고.

- [x] `SettingView`의 언어 Section을 선택 목록에서 **현재 적용된 언어를 표시하는 행 하나**로 교체하고, 탭하면 `UIApplication.openSettingsURLString`으로 iOS 설정 앱의 앱별 언어 설정으로 이동 (커밋 `ade7318`)
- [x] "재시작 필요" 알럿 제거 — 시스템 설정에서 언어를 바꾸면 iOS가 앱을 종료시키므로 안내가 불필요해짐. 대신 Section footer로 "설정에서 언어를 바꾸면 앱이 다시 시작됩니다"를 미리 안내 (커밋 `ade7318`)
- [x] (확인 결과 반영) 최초 실행 시 한국어 강제 로직(`AppLanguage.applyInitialLanguageIfNeeded`) 제거 (커밋 `de33dc2`, `aa8a712`) — `AppleLanguages`는 iOS 앱별 언어 설정과 **같은 저장소**라 비공식 직접 쓰기를 남겨둘 이유가 없다고 판단. 기기 언어가 그대로 적용되며, `ko`/`en` 외 언어 기기는 `developmentRegion`(`ko`) 폴백으로 한국어가 되어 기존 의도도 대부분 유지된다. `MyApp.init()`의 호출도 함께 제거
- [x] `AppLanguage.current`를 `UserDefaults`의 `AppleLanguages` 읽기에서 `Bundle.main.preferredLocalizations` 기준으로 변경 — 실제로 앱에 적용된 로컬라이제이션을 표시 (커밋 `aa8a712`)
- [x] `Localizable.xcstrings`에 신규 문구 `en` 번역 추가 및 제거된 재시작 알럿 문구 2개 삭제 (커밋 `7894242`)
- [x] (1차 검증 후속) 설정 앱에 언어 항목이 노출되지 않던 문제 수정 — iOS는 **기기의 선호하는 언어가 2개 이상일 때만** 앱별 언어 항목을 표시한다. 앱 번들은 `en.lproj`/`ko.lproj` 2개 로컬라이제이션 조건을 이미 충족했으므로 원인은 앱이 아닌 기기 설정 쪽이었고, `Info.plist`에 `UIPrefersShowingLanguageSettings = YES`를 추가해 언어가 하나뿐인 기기에서도 항상 노출되도록 함 (커밋 `a0e967f`)
- [x] 검증 완료 — 설정 앱의 언어 항목 노출, 언어 변경 후 복귀 시 새 언어 적용 모두 **실기기에서 정상 확인**. 시뮬레이터에서는 앱 내 "표시 언어" 행이 설정 최상단만 열고 앱 페이지까지 들어가지 못하는데, `UIApplication.openSettingsURLString`의 알려진 시뮬레이터 한계이며 실기기에서는 정상 동작함을 확인했다 (코드 변경 불필요)

## Task 14 — `feature/branding-visual-language`
브랜딩·비주얼 언어 확정. 1.0 착수 순서 2번 항목을 백로그에서 Task로 승격. 상세 배경·방향은 [PLAN.md](./PLAN.md)의 "백로그 C" 참고. 착수 시점(2026-09-02) 사용자 결정으로 범위를 **도식 표기 규칙 문서화 + 색 의미 정리**로 좁혔다 (앱 이름 현행 유지, 색 자산 리네임 제외).

- [x] `VISUAL_LANGUAGE.md` 신설 — 이미 화면에 구현된 표기를 실측해 규칙으로 승격. 슬롯 3종 표기, 화살표 표기, 라벨·배지, 색 대응표, 코드 패널 예외, 이탈 목록, 새 도식 체크리스트
- [x] 색 의미 축 분리 확정 — **테두리 색 = 종류(값/포인터/빈칸), 배경 색 = 상태(에러/강조)**. 같은 색을 두 축에 걸쳐 쓰지 않는다는 규칙을 명문화
- [x] 앱 이름/부제 확정 — `Pointer Quest` / `메모리의 미로` 현행 유지 (SSC 제출명 `Pointer Quest: The Memory Maze`는 폐기). 앱 아이콘은 1.0 4번(App Store 심사 대비)으로 이관
- [x] 색 자산 이름은 유지하고 의미만 정의 — 리네임은 참조 지점이 여러 파일에 걸쳐 회귀 부담이 있고, 도식 규칙 확정에 필요한 것은 이름이 아니라 의미 정의라고 판단
- [x] 사용자 검토 후 `develop` 병합 — 문서만 변경되어 빌드·시뮬레이터 검증 대상 없음. 커밋 5개(포매팅 1 + 문서 4)를 `--no-ff`로 병합(`ee55329`), `origin/develop` 푸시 및 로컬 브랜치 삭제 완료
- [x] (작업 중 발견) 마크다운 헤더 뒤 빈 행 제거 규칙이 기존 문서에 적용돼 있지 않던 것을 일괄 정리 — PLAN 52곳, PROGRESS 33곳, TODO 17곳, STYLE_GUIDE 12곳 (커밋 `6d33122`). 포매팅만 담은 커밋을 먼저 쌓고 그 위에 내용을 얹어 내용 diff에 공백 변경이 섞이지 않게 했다. `PROPOSAL.md`는 SSC 제출 시점의 기록 문서라 제외

### Task 14에서 발견한 이탈 (수정은 별도 Task)
백로그 C의 Non-goal("규칙에 어긋나는 곳을 목록으로만 남긴다")에 따라 수정하지 않고 기록만 한다. 상세는 `VISUAL_LANGUAGE.md` §7 참고.

- [ ] `MemoryItem.swift:74` — 에러 시 테두리가 `Red`로 덮여 값/포인터 구분이 사라짐. 축 분리를 어기는 유일한 지점
- [ ] `MainView.swift:5-7` — 챕터 그라데이션이 상태 색(`Green`/`Red`)을 장식으로 재사용
- [ ] `LessonRow.swift:40` — 완료 체크마크가 자산이 아닌 시스템 `.green` 하드코딩
- [ ] 색 자산 10개 중 9개가 다크 모드 대응 없음 (light appearance만 정의). 상태 배경 30%의 다크 대비 미확인
- [ ] 미사용 자산 `LightBlown`/`Text1` 정리
- [ ] 색 자산 의미 기반 리네임 (이번 Task에서 보류)

## Task 15 — `feature/lesson-zero-variables`
학습 효과 보강 B-2 "레슨 0 — 변수와 메모리". 1.0 착수 순서 3번의 첫 항목을 Task로 승격. 상세 배경·방향은 [PLAN.md](./PLAN.md)의 "백로그 B" 참고.

- [x] 샌드박스 레슨 id를 `0` → `100`(챕터 밖 예약 번호대)으로 이동해 레슨 0에 id 0을 비워 줌
- [x] `SuccessCondition`에 `.inspectedAll(indices:)` 케이스 추가 — 지정된 슬롯을 모두 탭해 확인하면 클리어
- [x] `MemoryGridVM`에 관찰 기록 경로 추가 — `inspectedIndices`로 확인한 슬롯을 누적하고, 값 슬롯 탭 시 `recordInspection(of:)`이 "이름·주소·값"과 남은 개수를 코드 패널에 표시. 이미 확인한 슬롯을 다시 탭해도 완료 알럿이 재노출되지 않도록 **처음 확인한 경우에만** 판정한다. `reset()`(→ `setupLevel`) 시 함께 초기화
- [x] 레슨 0 데이터 등록 — 챕터 1 맨 앞, 값 슬롯 3개(`age` 20 / `score` 100 / `level` 7)만 배치하고 포인터·화살표는 등장시키지 않음
- [x] `Localizable.xcstrings`에 신규 문구 5개의 `en` 번역 추가 — 빌드 산출물의 `.stringsdata`(소스가 실제로 방출한 키)와 `en.lproj/Localizable.strings`(카탈로그가 컴파일한 키)를 대조해 5개 모두 일치함을 확인(STALE 없음)
- [x] 사용자 시뮬레이터 검증 — 레슨 0 행 노출, 상자 3개 탭 시 코드 패널 문구와 남은 개수, 3개 모두 확인 시 완료 알럿·체크마크 모두 정상 확인
- [x] (검증 중 제기) "리셋을 누르면 완료 팝업이 다시 뜨는 것이 맞는가" 확인 — **정상 동작으로 확정.** 임시 `print`를 넣고 `simctl launch --console-pty`로 로그를 받아 판별했다. 리셋 시점 로그는 `isSuccess: false -> false`이고 그 직후 `finishLevel()`이 찍히지 않는다. 팝업은 리셋 **이후 상자 3개를 다시 확인했을 때** 뜨며, 이는 레슨 1~3에서 리셋 후 포인터를 다시 연결하면 완료 알럿이 다시 뜨는 것과 같은 재클리어 동작이다. 진단 `print`는 제거하고 재빌드해 잔여 0건 확인

## 백로그
2026-08-14 기준으로 1.0 출시 전 항목과 출시 후 업데이트 항목을 구분했다. 상세 배경·방향은 [PLAN.md](./PLAN.md)의 "출시 로드맵" 참고.

### 1.0 (출시 전)
착수 순서는 아래 번호 순으로 확정했다 (2026-08-14). 근거는 `PLAN.md`의 "출시 로드맵" 참고.

- [x] **1. 언어 변경 방식 개선** — Task 13으로 완료. 앱 내 언어 선택 목록을 없애고, 현재 적용된 언어만 표시한 뒤 탭하면 iOS 설정 앱의 앱별 언어 설정으로 이동시킨다. 시스템 설정에서 언어를 바꾸면 iOS가 앱을 종료시키므로 돌아왔을 때 자동으로 새 언어가 적용되어, 기존의 "재시작해주세요" 알럿이 불필요해진다 (상세는 `PLAN.md`의 "백로그 A")
- [x] **2. 브랜딩·비주얼 언어 확정** — Task 14로 완료. 앱 이름/부제/아이콘/색 팔레트에 더해, 학습 효과 보강의 선행 조건인 **도식 표기 규칙**(값 vs 포인터 구분, 화살표 표기, 색이 의미하는 것)까지 확정한다. 색 팔레트 교체 자체는 하드코딩 색상이 0건이라 비용이 거의 없고, 이 항목을 먼저 두는 실익은 도식 표기 규칙에 있다 (상세는 `PLAN.md`의 "백로그 C")
- [ ] **3. 학습 효과 보강** — 포인터 개념을 모르는 사용자에게 실제 학습 효과가 있는지에 대한 우려에서 출발. 후보안 6개 중 1.0 범위를 아래 3개로 확정했다 (별도 이론 화면은 만들지 않고 레슨 흐름 안에 개념 설명을 녹이는 방향). 상세는 `PLAN.md`의 "백로그 B" 참고
  - [x] B-2: 레슨 0 "변수와 메모리" 추가 — Task 15로 구현 완료(검증 대기). 레슨 1이 전제하는 "변수 = 이름표 붙은 상자 / 주소 = 상자 번호"를 기존 그리드로 먼저 보여준다 (Task 11의 `SlotSeed.variableName` 재사용)
  - [ ] B-1: 레슨별 개념 카드 — 그리드 진입 직전 3~5문장 + 도식 1개, 그리드 상단 `(i)` 버튼으로 재열람
  - [ ] B-4: 레슨 마무리 요약 — 완료 알럿에 "이번에 배운 것" 한 문장과 다음 레슨 연결 추가
- [ ] **4. App Store 심사 대비 항목 점검** (개인정보처리방침, 스크린샷, 지원 언어 등)

### 1.x (출시 후 업데이트)
- [ ] 학습 효과 보강 중 1.0에서 제외한 항목 — B-3(예측→확인 단계), B-5(용어집 화면), B-6(오개념 지목형 피드백)
- [ ] Chapter 2~5 실제 레슨 콘텐츠 저작 — 분량이 가장 크고 출시를 막을 이유가 없어 1.0 이후 업데이트로 분리. 남은 백로그 중 **가장 마지막** 순서로 진행
