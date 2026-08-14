# SwiftUI 코딩 스타일 가이드

이 문서는 Pointer Quest의 Swift/SwiftUI 코드 작성 규칙을 정의한다. 규칙은 새로 만든 것이 아니라, 프로젝트 저자가 직접 작성한 원본 코드(git tag `1.0`)에서 실제로 반복되는 관례를 추출해 문서화한 것이다. 새 코드를 작성하거나 기존 코드를 수정할 때 이 문서를 기준으로 삼는다.

## 1. 포매팅

- 들여쓰기는 **space 2칸**을 사용한다. 탭 문자는 쓰지 않는다.
- 파일 최상단에 `import` 구문을 두고, 그 아래 **빈 줄 한 개**를 둔 뒤 타입 선언을 시작한다.
- UI를 다루지 않는 모델/유틸리티 타입은 `import Foundation`, View나 `Color`/`Image` 등 SwiftUI 타입을 쓰는 파일은 `import SwiftUI`를 쓴다.
- 파일 끝에는 개행 문자 하나만 둔다.
- 빈 줄에 들여쓰기 공백이 남는 것은 Xcode 기본 동작이라 원본 코드에도 섞여 있다. 의도적인 스타일이 아니므로 **일부러 넣지도, 일괄로 지우지도 않는다** — 공백만 바꾸는 커밋은 diff만 키우고 얻는 게 없다.

## 2. 문서 주석

- 타입 선언 위에는 `///` 문서 주석으로 **한국어** 한 줄 설명을 단다.
- 의미가 자명하지 않은 저장 프로퍼티에도 `///` 주석을 단다. 여러 줄이 필요하면 `///`을 이어서 쓴다.
- 코드 흐름 중간의 설명은 `//` 한 줄 주석으로 쓴다. 이 역시 한국어로 쓴다.
- C 언어 개념을 설명할 때는 실제 C 코드 예시를 주석에 함께 적는다.

```swift
/// 컴퓨터의 메모리 Cell
struct MemorySlot: Identifiable, Hashable {
  /// 주소값 (ex: "0x7FFEE")
  let address: String
  /// pointer일 때, 가리키는 대상의 주소 저장
  /// C 언어의 `int *p = &a;` 에서 `p`가 가진 `&a` 값을 의미
  var pointingTo: String?
}
```

## 3. 타입 내부 선언 순서

View 타입 안에서는 다음 순서를 지킨다.

1. 외부에서 주입받는 `let` 프로퍼티
2. 프로퍼티 래퍼가 붙은 상태 프로퍼티 (`@StateObject`, `@ObservedObject`, `@AppStorage`, `@State`)
3. `init` (커스텀 초기화가 필요한 경우에만)
4. `private let` 상수 (레이아웃 상수 등)
5. `var body: some View`
6. `private func` 헬퍼

주입 `let`이 상태 프로퍼티보다 먼저 온다. `MemoryItem`이 `let slot` 다음에 `@ObservedObject var vm`을 두는 순서가 기준이다. 주입받는 값이 없으면 상태 프로퍼티가 그대로 맨 위에 온다(`MemoryGridView`, `AppView`).

`body` 앞뒤로는 빈 줄을 하나 둔다.

```swift
/// 메모리 Grid 화면
struct MemoryGridView: View {
  @StateObject private var vm: MemoryGridVM

  init(lesson: Lesson = LessonData.lessons[0]) {
    _vm = StateObject(wrappedValue: MemoryGridVM(lesson: lesson))
  }

  private let columns: [GridItem] = [
    .init(.adaptive(minimum: 100), spacing: 16)
  ]

  var body: some View {
    ...
  }
}
```

## 4. 서브뷰 분리

`body`가 길어지면 뷰 조각을 `private extension`으로 빼낸다.

- 파라미터가 **없는** 뷰 조각은 **대문자로 시작하는 계산 프로퍼티**로 만든다. SwiftUI 뷰 이름처럼 읽히게 하기 위한 의도적인 관례다. (`var Title: some View`, `var ContinueButton: some View`)
- 파라미터가 **있는** 뷰 조각은 **소문자로 시작하는 함수**로 만든다. (`func lessonRow(lesson:colors:) -> some View`)
- 이 `extension`은 타입 본체 바로 아래에 두고 `private extension TypeName { ... }` 형태로 쓴다.

```swift
struct MainView: View {
  var body: some View {
    VStack(spacing: 0) {
      Title

      Cards
    }
  }
}

private extension MainView {
  var Title: some View {
    ...
  }

  func lessonRow(lesson: Lesson, colors: [Color]) -> some View {
    ...
  }
}
```

## 5. 뷰 본문의 여백

- 스택(`VStack`/`HStack`/`ZStack`) 안의 자식 뷰들은 **빈 줄로 구분**한다. 특히 `Spacer()` 앞뒤는 반드시 띄운다.
- 뷰 하나에 붙는 모디파이어 체인은 붙여 쓴다. 체인 중간에는 빈 줄을 넣지 않는다.

```swift
VStack(alignment: .leading, spacing: 8) {
  Text(slot.address)
    .font(.system(.caption, design: .monospaced))
    .foregroundStyle(.secondary)

  Spacer()

  Text(slot.value.description)
    .font(.title2)
}
```

## 6. 인자 줄바꿈

- 인자가 짧으면 한 줄에 쓴다.
- 인자가 길거나 개수가 많아 한 줄이 길어지면 **인자 하나당 한 줄**로 개행하고, 닫는 괄호는 호출부와 같은 들여쓰기 위치에 둔다.
- 뒤에 클로저가 오는 API는 트레일링 클로저 문법을 쓴다. `Button { } label: { }`, `Label { } icon: { }` 형태를 그대로 사용한다.

```swift
WelcomeView(
  isPresented: $isWelcomePresented,
  isOnboardingPresented: $isOnboardingPresented,
  isAlertPresented: $isAlertPresented
)

Button {
  vm.reset()
} label: {
  Image(systemName: "arrow.counterclockwise")
}
```

## 7. guard / 조기 반환

- 조건이 하나이고 짧으면 `guard ... else { return }`을 **한 줄로 붙여 쓴다**. 이것이 기본형이다.
- 조건이 여러 개이거나 한 줄이 길어지면 `else`를 다음 줄로 내린다.

```swift
// 기본형 — 조건 하나, 짧음
guard maxIndex > 0 else { return 0 }

// 길거나 조건이 여러 개일 때
guard let draggedAddress = droppedAddresses.first
else { return false }
```

## 8. 모델 타입

- 데이터 모델은 `struct`로 정의하고, 필요한 프로토콜(`Identifiable`, `Hashable`)을 채택한다.
- 모델에 종속된 열거형은 해당 타입 **안에 중첩**해 선언하고, 각 case에 `///` 주석을 단다.
- 정적 데이터 모음은 `LessonData`처럼 별도 타입의 `static let` 배열로 모아두고, 원소는 `.init(...)` 축약 표기로 쓴다.

```swift
struct MemorySlot: Identifiable, Hashable {
  ...

  /// 메모리 슬롯의 역할
  enum SlotType {
    /// 일반 변수
    case value
    /// 주소값
    case pointer
    /// 빈 공간
    case empty
  }
}
```

## 9. 색상과 이미지

- 색은 에셋 카탈로그 이름으로 참조한다. (`Color(.main)`, `Color(.systemGroupedBackground)`)
- 정사각형 이미지 크기는 프로젝트 확장 `Image.size(_:)`를 사용한다.

## 10. 프리뷰

- View 파일 하단에 `#Preview`를 둔다. 위에 빈 줄을 하나 둔다.
- 프리뷰에 필요한 모델은 `LessonData`의 실제 데이터를 쓰거나, `.init(...)`으로 최소한의 더미를 만든다.
- 단독으로 띄워도 의미가 없는 보조 레이어는 예외다. `ArrowDrawLayer`처럼 상위 뷰의 좌표 정보를 받아야만 그려지는 오버레이 뷰에는 `#Preview`를 두지 않는다.

```swift
#Preview {
  MainView()
}
```

## 11. 로컬라이제이션

- 사용자에게 보이는 문구는 소스에 **한국어**로 쓰고, `Localizable.xcstrings`에 `en` 번역을 채운다. (소스 언어 = `ko`)
- 데이터로 정의된 문구(`Lesson.title`, `LessonBlueprint.initialCodeLog` 등)는 `String`이 아니라 `LocalizedStringResource`로 선언한다.
- `Text(String)` 오버로드는 로컬라이즈되지 않는다. 헬퍼 함수가 문구를 받을 때는 파라미터 타입을 `LocalizedStringKey`나 `LocalizedStringResource`로 둔다.
- 대문자 변환은 `"...".uppercased()`가 아니라 `.textCase(.uppercase)` 모디파이어로 처리한다. 문자열을 가공하면 로컬라이즈 대상에서 빠진다.
