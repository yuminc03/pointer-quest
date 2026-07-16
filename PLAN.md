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

- "Mission" → "Goal/Lesson", "Level Clear! 🎉" → 학습 완료를 알리는 문구
- 잠금/에러 시각 효과는 재사용하되, 문구는 왜 틀렸는지 설명하는 학습형 문구로 다듬는다
- "Lv. N" 같은 게임 용어를 "Lesson N" 등으로 조정

### 4. 샌드박스(자유 탐험) 모드 추가

- 성공 조건 없이 자유롭게 포인터를 연결/해제할 수 있는 Playground 모드
- Main 화면에 별도 진입점 카드 추가

### 5. 진행 상황 저장 (가벼운 동기부여)

- 완료한 레슨 id를 `UserDefaults` 기반으로 저장, 카드에 체크마크만 표시 (XP/포인트 등 추가 수치 없음)

## 백로그 (다음 단계로 분리)

- Chapter 2~5 실제 레슨 콘텐츠 저작 (커리큘럼 상세는 별도 협의)
- 앱 이름/브랜딩/아이콘 재검토
- App Store 심사 대비 항목 점검 (개인정보처리방침, 스크린샷, 지원 언어 등)
