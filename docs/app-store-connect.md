# App Store Connect 등록 정보

1.0 제출에 필요한 항목을 한곳에 모은다. Task 24(스크린샷·메타데이터)에서 이 문서를 보고 그대로 입력한다. 문구는 한국어·영어 둘 다 등록한다.

**1.0.0은 심사를 통과해 App Store에 출시됐다** (2026-09-15 사용자 보고로 확인). 다음 버전을 올릴 때는 아래 "버전 표기 규칙"을 따른다.

## 등록할 주소 (2026-09-09 확정)
사용자가 Notion 페이지를 만들어 아래 두 주소로 확정했다. 원문 대조는 [privacy-policy.md](./privacy-policy.md)·[support.md](./support.md)를 쓴다.

| 항목 | 주소 |
|---|---|
| `Privacy Policy URL` | `https://lonalia.notion.site/Privacy-Policy-3d6e9fb9ac1880349b48d322882e2e14` |
| `Support URL` | `https://lonalia.notion.site/Pointer-Quest-3d6e9fb9ac1880c4aae6e40d8963fcd2` |

사용자가 준 주소는 `app.notion.com/p/...` 형식이었고, 같은 페이지를 가리키는 `notion.site` 주소로 바꿔 적었다. 상세는 아래 "주소 형식 주의" 참고.

## 앱 정보 (App Information)
언어와 무관한 항목이다.

| 항목 | 값 |
|---|---|
| Bundle ID | `com.lonalia.PointerQuest` |
| SKU | `pointerquest-1` (임의 문자열, 공개되지 않는다) |
| Primary Category | 교육 (Education) |
| Secondary Category | 참고 자료 (Reference) |
| Age Rating | 4+ (모든 항목 "없음") |
| Copyright | `2026 Chu Yumin` |
| Content Rights | 제3자 콘텐츠 없음 |
| Price | 무료 |
| Availability | 전체 국가 |

## 버전 정보 (1.0.0 출시)
| 항목 | 값 |
|---|---|
| Version | `1.0` (`MARKETING_VERSION`) |
| Build | `1` (`CURRENT_PROJECT_VERSION`) |
| 최소 iOS | 16.0 |
| 지원 기기 | iPhone 전용 (Task 21에서 축소) |
| 지원 언어 | 한국어(기본), 영어 |

### 버전 표기 규칙 (2026-09-15 확정)
- **1.1.0부터 `MAJOR.MINOR.PATCH` 세 자리로 표기한다.** `MARKETING_VERSION`과 git 태그를 같은 값으로 맞춘다
- 1.0은 앱 버전이 `1.0`, 태그가 `1.0.0`으로 표기가 달랐다. 이미 출시된 값이라 소급해 고치지 않는다
- 기능 추가는 MINOR(`1.1.0`), 출시 후 긴급 수정은 PATCH(`1.0.1`)를 올린다. 각각 Git Flow의 `release/`·`hotfix/` 브랜치에 대응한다
- 버전 값은 `project.yml`·`project.pbxproj`(Debug·Release)·`Info.plist` 세 곳에 함께 있다. 하나만 바꾸면 어긋난다
- 빌드 번호(`CURRENT_PROJECT_VERSION`)는 업로드할 때마다 올린다. 같은 버전 안에서 번호가 겹치면 업로드가 거부된다

## 한국어 메타데이터

### 이름 (30자 이내)
```
Pointer Quest
```

### 부제 (30자 이내)
```
포인터를 눈으로 배우는 법
```

### 프로모션 텍스트 (170자 이내, 심사 없이 수정 가능)
```
포인터가 어렵게 느껴지는 건 눈에 보이지 않기 때문입니다. 메모리를 격자로 펼쳐 놓고 직접 연결해 보면서, 주소가 무엇이고 왜 중요한지 감으로 익혀 보세요.
```

### 설명 (4000자 이내)
```
포인터는 C를 배우는 사람이 가장 먼저 막히는 벽입니다. 문법은 외웠는데 무슨 일이 일어나는지 그려지지 않기 때문입니다.

Pointer Quest는 메모리를 격자로 펼쳐 보여줍니다. 칸마다 주소가 붙어 있고, 값이 든 칸과 주소가 든 칸이 다르게 생겼습니다. 블록을 끌어다 연결하면 화살표가 그려지고, 옆의 코드 패널에 그 조작이 C 코드로 나타납니다. 손으로 옮긴 것이 곧 코드가 되는 셈입니다.

■ 이렇게 배웁니다
· 레슨에 들어가기 전 개념 카드가 그림 한 장과 서너 문장으로 핵심을 먼저 잡아줍니다
· 격자를 직접 조작하며 주소를 연결합니다
· 레슨을 마치면 방금 배운 것이 한 문장으로 정리됩니다

■ 챕터 1 · 주소와 포인터
· 레슨 0 변수와 메모리 — 변수는 이름표가 붙은 상자이고, 상자마다 번호가 있습니다
· 레슨 1 주소가 중요한 이유 — 값이 아니라 주소를 다루면 무엇이 달라지는지 봅니다
· 레슨 2 징검다리 포인터 — 포인터도 자기 주소를 가지므로 다른 포인터가 가리킬 수 있습니다
· 레슨 3 체인 연결 — 주소를 이어 붙여 데이터에 도달하는 경로를 만듭니다

■ 플레이그라운드
목표도 정답도 없습니다. 자유롭게 연결하고 끊으며 확인해 보세요. 여기서는 아무것도 망가지지 않습니다.

■ 알아두실 점
· 인터넷에 연결하지 않습니다. 계정도 로그인도 없습니다
· 개인정보를 수집하지 않으며, 진행 상황은 기기에만 저장됩니다
· 광고가 없습니다
· 챕터 2 이후는 다음 업데이트에서 추가됩니다
```

### 키워드 (100자 이내, 쉼표로 구분·공백 없이)
```
포인터,C언어,프로그래밍,코딩,메모리,주소,컴퓨터공학,CS,학습,자료구조,입문,C
```

### 새로운 기능 (What's New)
1.0 최초 출시이므로 비워 두거나 아래를 쓴다.
```
Pointer Quest의 첫 번째 버전입니다.
```

## 영어 메타데이터

### 이름 (30자 이내)
```
Pointer Quest
```

### 부제 (30자 이내)
```
See how pointers work
```

### 프로모션 텍스트 (170자 이내)
```
Pointers feel hard because you cannot see them. Lay memory out as a grid, connect the cells yourself, and get a feel for what an address is and why it matters.
```

### 설명 (4000자 이내)
```
Pointers are where most people learning C get stuck. The syntax is memorable; what actually happens is not.

Pointer Quest lays memory out as a grid. Every cell carries an address, and a cell holding a value looks different from one holding an address. Drag a block to connect it and an arrow appears, while the code panel beside it writes the same move as C. What you moved by hand becomes the code.

■ How it teaches
· Before each lesson, a concept card gives you one diagram and a few sentences
· You connect addresses by working the grid directly
· When the lesson ends, what you just learned is summed up in one line

■ Chapter 1 · Address & Pointers
· Lesson 0, Variables and Memory — a variable is a box with a name tag, and every box has a number
· Lesson 1, The Importance of Addresses — what changes when you handle the address instead of the value
· Lesson 2, Stepping Stone Pointer — a pointer has an address too, so another pointer can point at it
· Lesson 3, Chain Connection — link addresses together to build a path to the data

■ Playground
No objective, no right answer. Connect and disconnect freely. Nothing breaks here.

■ Good to know
· No internet connection. No account, no sign-in
· No personal data is collected, and progress stays on your device
· No ads
· Chapter 2 and beyond arrive in future updates
```

### 키워드 (100자 이내)
```
pointer,C language,programming,coding,memory,address,computer science,CS,learn,data structure,C
```

### What's New
```
The first release of Pointer Quest.
```

## 스크린샷
Task 24에서 찍는다. **두 벌을 올린다** — 6.9인치와 6.5인치다. 이유는 아래 "6.5인치 벌이 따로 필요했다" 참고.

| 항목 | 값 |
|---|---|
| 크기 | 6.9인치 `1320 x 2868`, 6.5인치 `1284 x 2778` |
| 촬영 기기 | **iPhone 17 Pro Max 시뮬레이터 (iOS 26.5)** |
| 장수 | 벌마다 5장 (Apple 상한은 10장) |
| 언어 | **한국어 한 벌** (2026-09-10 변경) |
| 형식 | PNG, **알파 채널 없음** |
| 최종본 위치 | `docs/screenshots/ko/`(6.9) · `docs/screenshots/ko-6.5/`(6.5) |

찍을 화면이다. 목록 화면을 먼저 두어 앱의 구조가 한눈에 들어오게 한다.

1. 레슨 목록 (챕터 1 전체가 보이는 상태)
2. 개념 카드 (도식이 있는 화면)
3. 레슨 1에서 포인터가 값을 가리킨 상태 (화살표와 코드 패널이 함께 보인다)
4. 플레이그라운드에서 이중 포인터를 만든 상태 (코드 패널에 C 세 줄)
5. 완료 알럿과 "이번에 배운 것" 요약

**레슨 3 체인 화면은 넣지 않는다** (2026-09-10 결정). 그 화면의 코드 패널에 설명 없는 `int ***`가 나오고, 그것은 `TODO.md`의 Task 28에서 닫을 항목이다. **설명이 붙기 전 화면을 스토어에 올리지 않는다.** 덕분에 Task 28이 스크린샷을 다시 찍게 만들지도 않는다.

### 6.5인치 벌이 따로 필요했다 (2026-09-11 실측)
**"6.9인치만 올리면 된다"는 이 문서의 서술이 실제 등록에서 틀렸다.** 사용자가 업로드하다 막혔고, App Store Connect가 요구한 크기는 `1242 x 2688` 또는 `1284 x 2778`이었다. 둘 다 6.5인치 값이다.

- **6.9인치 벌은 그대로 쓴다.** 6.9인치 자리에 올리면 되고 규격도 맞다
- **6.5인치 벌을 한 벌 더 만들었다.** 6.5인치가 받는 두 크기 중 큰 쪽인 `1284 x 2778`을 쓴다
- 다음에 또 다른 자리에서 막히면 **그 화면이 말하는 크기를 그대로 믿고 한 벌 더 만든다.** 이 문서의 서술보다 등록 화면이 정본이다

### 다른 크기로 한 벌 더 만드는 방법
**늘리거나 줄이지 않는다.** 아트보드의 루트 치수만 바꿔 다시 렌더하면 글자가 원래 크기 그대로 남는다. 목업은 세로 여백이 넉넉해서 100px 정도 줄어도 잘리지 않는다.

```
cp docs/screenshots/frame/*.dc.html <작업폴더>/frame/
sed -i '' 's/width: 1320px; height: 2868px;/width: <너비>px; height: <높이>px;/' <작업폴더>/frame/*.dc.html
```

아트보드가 `../raw/`를 상대 경로로 참조하므로 `docs/screenshots/raw/`도 같은 구조로 복사한 뒤, 아래 "최종본을 다시 만드는 방법"의 크롬 명령에서 `--window-size`를 같은 값으로 준다.

### 영어 벌은 올리지 않는다 (2026-09-10 변경)
착수 전 결정은 한국어·영어 둘 다였으나 사용자 판단으로 한국어 한 벌만 올린다. **App Store Connect는 어떤 언어에 스크린샷이 없으면 기본 언어의 벌을 그대로 보여주므로** 영어 지역에서도 화면이 비지 않는다. 앱 자체는 영어를 그대로 지원한다.

### 시뮬레이터 컷을 그대로 올리지 않는다 (2026-09-10 결정)
컷을 iPhone 베젤 목업 안에 넣고 위에 한 줄 문구를 얹는다. 사용자가 참고 디자인을 제시해 정했다.

| 장 | 배경색의 근거 | 문구 |
|---|---|---|
| 1 레슨 목록 | `Main` 계열 연한 파랑 | 레슨을 따라가며 / 포인터를 익힙니다. |
| 2 개념 카드 | `Main` 계열 연한 파랑 | 개념 카드가 먼저 / 핵심을 짚어줍니다. |
| 3 레슨 1 연결 | `Main` 계열 연한 파랑 | 블록을 끌어다 / 주소를 연결합니다. |
| 4 플레이그라운드 | `Deco` 계열 연한 보라 | 손으로 옮긴 것이 / 곧 C 코드가 됩니다. |
| 5 레슨 완료 | `Green` 계열 연한 초록 | 레슨이 끝나면 / 한 문장이 남습니다. |

- **배경색은 [VISUAL_LANGUAGE.md](../VISUAL_LANGUAGE.md) §5의 대응을 따랐다.** 샌드박스가 `Deco`, 완료 체크마크가 `Green`이므로 4·5번만 색을 달리한다. 새로 고른 색이 아니다
- **베젤 안에 가짜 상태 표시줄을 그리지 않는다.** 시뮬레이터 컷에 다이나믹 아일랜드와 상태 표시줄이 이미 들어 있어, 덧그리면 두 겹이 된다
- 목업 소스와 다시 만드는 방법은 `TODO.md`의 Task 24 절에 있다

**상태 표시줄이 `9:41`이 아니다** (2026-09-10). 전달받은 컷의 시각이 `4:47`·`4:48`이고 셀룰러가 비어 있다. 아래 "촬영 조건"의 `status_bar override`가 이번 촬영에 걸리지 않았다. **App Store Connect는 픽셀 크기만 검사하므로 반려되지 않으며, 사용자 판단으로 이대로 올린다.** 다시 찍을 일이 생기면 그때 조건을 맞춘다.

### iOS 버전을 맞춘다
**iOS 18이 아니라 iOS 26으로 찍는다.** App Store Connect는 픽셀 크기만 검사하므로 iOS 18 스크린샷도 반려되지는 않지만, 이 앱은 Xcode 26.6의 iOS 26.5 SDK로 빌드되어 **iOS 26 기기에서는 탭 바가 떠 있는 캡슐로 바뀌는 등 시스템 외형이 다르다.** iOS 18로 찍으면 실제 사용자가 보는 화면과 어긋난다.

iPhone 17 Pro Max(iOS 26.5)도 `1320 x 2868`이라 크기 규격은 바뀌지 않는다.

### 크기를 실측으로 두 번 정정했다 (2026-09-10 · 2026-09-11)
2026-09-11에 **"6.9인치 한 벌이면 충분하다"가 틀린 것으로 드러났다.** 위 "6.5인치 벌이 따로 필요했다" 참고. 아래는 2026-09-10의 1차 정정이다.

이 절에 적혀 있던 `1290 x 2796`은 **6.9인치가 아니라 6.7인치(iPhone 15 Pro Max) 값이다.** iPhone 16 Pro Max 시뮬레이터에서 실제로 찍어 `1320 x 2868`을 확인했고, Apple 문서에서 6.9인치 자리가 `1260 x 2736`·`1290 x 2796`·`1320 x 2868` 셋을 모두 받는 것도 확인했다. 셋 다 통과하지만 **기기 해상도 그대로인 `1320 x 2868`을 쓴다** — 축소하면 글자가 뭉갠다.

### 알파 채널을 반드시 제거한다
**App Store Connect는 알파 채널이 있는 이미지를 거부하는데 `simctl io screenshot`은 RGBA로 내보낸다.** 그대로 올리면 업로드 단계에서 막힌다.

- 스크린샷은 전 픽셀이 불투명(`alpha` 255)이라 **알파 채널만 떼어내면 색이 달라지지 않는다.** 흰 배경에 합성할 필요가 없다
- 저장소에 커밋한 파일은 이미 알파를 제거한 것이다. PNG 색 타입이 `2`(RGB)이면 제거된 것이고 `6`(RGBA)이면 아직인 것이다
- **`sips`로는 떨어지지 않는다** (2026-09-10 실측). `-s format png`를 줘도 색 타입이 그대로다. CoreGraphics로 `noneSkipLast` 컨텍스트에 다시 그려야 실제로 빠진다
- 확인은 `sips -g hasAlpha <파일>`로 한다. `no`면 제거된 것이다
- **최종본은 이 단계가 필요 없다.** 목업을 헤드리스 크롬으로 내보내면 처음부터 알파가 없다

### 촬영 조건
다시 찍을 때 같은 조건을 재현하기 위해 남긴다.

- **상태 표시줄을 고정한다** — `simctl status_bar override`로 시각을 `9:41`, 배터리 100% 충전, 셀룰러·와이파이를 가득 채운다. 실제 시각과 배터리가 찍히면 벌마다 달라진다

```
xcrun simctl status_bar <기기> override --time "9:41" \
  --batteryState charged --batteryLevel 100 \
  --cellularMode active --cellularBars 4 --wifiMode active --wifiBars 3
```

- **언어는 실행 인자로 바꾼다** — 기기 언어 설정을 건드리지 않고 한 벌씩 찍을 수 있다

```
xcrun simctl launch <기기> com.lonalia.PointerQuest -AppleLanguages "(en)"
```

- **온보딩 시트를 미리 닫는다** — 앱 컨테이너의 `com.lonalia.PointerQuest.plist`에 `isOnboardingWatched`를 `true`로 넣는다. 넣지 않으면 첫 실행마다 환영 시트가 덮는다

## 제출 전 확인할 것
1.0.0이 심사를 통과해 출시되면서 모두 닫혔다 (2026-09-15). 다음 버전을 제출할 때도 같은 목록으로 다시 확인한다.

- [x] `Privacy Policy URL` — 위 표의 `notion.site` 주소로 등록
- [x] `Support URL` — 위 표의 `notion.site` 주소로 등록
- [x] 앱 안 방침 링크(`SettingView`)를 같은 주소로 교체
- [x] App Privacy — **"Data Not Collected"** 선택. 네트워크 코드가 0건이고 저장은 `UserDefaults` 두 키뿐이라 수집 항목이 없다
- [x] 수출 규정 — `ITSAppUsesNonExemptEncryption`을 `false`로 `Info.plist`에 넣었다 (커밋 `2190518`). 빌드 산출물의 `Info.plist`에 값이 들어간 것까지 확인했다
- [x] 심사 메모(App Review Information) — 계정이 없으므로 로그인 정보 불필요. "챕터 2 이후는 준비 중 표시이며 의도된 상태"라고 적어 두면 오해를 막는다

## Notion 쪽 마무리 (2026-09-10 완료)
2026-09-09 실측에서 열려 있던 항목 2건을 사용자가 Notion에서 닫았고, 2026-09-10 같은 방식으로 다시 실측해 확인했다.

- [x] **두 페이지 본문이 채워졌다.** 방침·지원 모두 한국어와 English 두 절이 저장소 원문 그대로 들어가 있다. 계정 없이 보낸 본문 요청으로 확인했다
- [x] **공유 권한이 읽기 허용으로 낮아졌다.** 공개 권한이 `read_and_write`에서 `reader`로 바뀌었고, 편집·댓글 가능 여부도 함께 꺼졌다. `requireLogin`은 그대로 `false`라 심사자가 계정 없이 읽을 수 있다

## 주소 형식 주의
**`app.notion.com/p/...` 주소는 App Store Connect에 넣지 않는다.**

- 두 페이지 모두 **로그인 없이 읽히는 것은 확인했다.** Notion 공개 페이지 정보에 `requireLogin: false`가 오고, 계정 없이 보낸 본문 요청에도 페이지가 그대로 왔다
- 그럼에도 `app.notion.com`은 로그인한 사용자의 작업 공간을 여는 주소다. 계정이 없는 심사자에게 보여줄 자리에는 같은 페이지를 가리키는 `https://lonalia.notion.site/...`를 쓴다
- `notion.site` 주소는 페이지 우상단 **공유**에서 얻는다. 주소 끝의 32자리 식별자가 같으면 같은 페이지다
- 심사자는 계정 없이 방침을 읽을 수 있어야 한다. 열리지 않으면 이 사유만으로 반려된다
- 다른 앱에 이미 등록해 둔 주소도 같은 형식인지 다시 확인할 값어치가 있다
