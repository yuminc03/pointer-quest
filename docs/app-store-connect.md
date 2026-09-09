# App Store Connect 등록 정보

1.0 제출에 필요한 항목을 한곳에 모은다. Task 24(스크린샷·메타데이터)에서 이 문서를 보고 그대로 입력한다. 문구는 한국어·영어 둘 다 등록한다.

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

## 버전 정보 (1.0)
| 항목 | 값 |
|---|---|
| Version | `1.0` (`MARKETING_VERSION`) |
| Build | `1` (`CURRENT_PROJECT_VERSION`) |
| 최소 iOS | 16.0 |
| 지원 기기 | iPhone 전용 (Task 21에서 축소) |
| 지원 언어 | 한국어(기본), 영어 |

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
Task 24에서 찍는다. 기기 축을 iPhone 하나로 줄였으므로 6.9인치 한 벌이면 나머지 크기는 Apple이 축소해 쓴다.

| 항목 | 값 |
|---|---|
| 필수 크기 | 6.9인치 (iPhone 16 Pro Max, 1290 x 2796) |
| 장수 | 3~5장 |
| 언어 | 한국어·영어 각각 한 벌 |

찍을 화면 후보다. 목록 화면을 먼저 두어 앱의 구조가 한눈에 들어오게 한다.

1. 레슨 목록 (챕터 1 전체가 보이는 상태)
2. 개념 카드 (도식이 있는 화면)
3. 그리드에서 포인터가 값을 가리킨 상태 (화살표가 그려진 화면)
4. 코드 패널이 함께 보이는 상태
5. 플레이그라운드

## 제출 전 확인할 것
- [ ] `Privacy Policy URL` — 위 표의 `notion.site` 주소로 등록
- [ ] `Support URL` — 위 표의 `notion.site` 주소로 등록
- [x] 앱 안 방침 링크(`SettingView`)를 같은 주소로 교체
- [ ] App Privacy — **"Data Not Collected"** 선택. 네트워크 코드가 0건이고 저장은 `UserDefaults` 두 키뿐이라 수집 항목이 없다
- [ ] 수출 규정 — 암호화를 쓰지 않으므로 `ITSAppUsesNonExemptEncryption`을 `false`로 `Info.plist`에 넣어 매 업로드마다 묻지 않게 한다
- [ ] 심사 메모(App Review Information) — 계정이 없으므로 로그인 정보 불필요. "챕터 2 이후는 준비 중 표시이며 의도된 상태"라고 적어 두면 오해를 막는다

## 제출 전 Notion 쪽에서 마무리할 것
2026-09-09 두 페이지를 실측해 확인한 항목이다. 둘 다 Notion에서만 고칠 수 있어 코드 변경 대상이 아니다.

- [ ] **두 페이지 본문이 비어 있다.** 제목만 있고 그 아래는 빈 문단 하나뿐이다. [privacy-policy.md](./privacy-policy.md)·[support.md](./support.md)의 원문을 붙여넣어야 한다
- [ ] **링크를 가진 사람이 편집할 수 있다.** 공개 권한이 `read_and_write`로 열려 있어, 주소를 아는 누구나 방침 문구를 고칠 수 있다. 공유 설정을 **읽기 허용**으로 낮춘다

## 주소 형식 주의
**`app.notion.com/p/...` 주소는 App Store Connect에 넣지 않는다.**

- 두 페이지 모두 **로그인 없이 읽히는 것은 확인했다.** Notion 공개 페이지 정보에 `requireLogin: false`가 오고, 계정 없이 보낸 본문 요청에도 페이지가 그대로 왔다
- 그럼에도 `app.notion.com`은 로그인한 사용자의 작업 공간을 여는 주소다. 계정이 없는 심사자에게 보여줄 자리에는 같은 페이지를 가리키는 `https://lonalia.notion.site/...`를 쓴다
- `notion.site` 주소는 페이지 우상단 **공유**에서 얻는다. 주소 끝의 32자리 식별자가 같으면 같은 페이지다
- 심사자는 계정 없이 방침을 읽을 수 있어야 한다. 열리지 않으면 이 사유만으로 반려된다
- 다른 앱에 이미 등록해 둔 주소도 같은 형식인지 다시 확인할 값어치가 있다
