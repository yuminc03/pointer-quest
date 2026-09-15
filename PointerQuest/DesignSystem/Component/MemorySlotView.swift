import SwiftUI

/// 메모리 한 칸(`MemorySlot`)을 그리는 표시 전용 뷰
/// 드래그·드롭 같은 상호작용을 담지 않으므로 그리드 밖(개념 카드 도식 등)에서도 같은 표기로 재사용한다
struct MemorySlotView: View {
  let slot: MemorySlot

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      // 주소와 변수명은 칸 폭보다 길어질 수 있다(ex: 0x703C + treasure).
      // 말줄임표로 잘리면 학습에 필요한 정보가 사라지므로 줄이지 않고 글자 크기를 줄여 맞춘다
      HStack(spacing: 4) {
        Text(slot.address)
          .font(.system(.caption, design: .monospaced))
          .foregroundStyle(.secondary)

        if let variableName = slot.variableName {
          Text(variableName)
            .font(.system(.caption2, design: .monospaced))
            .fontWeight(.bold)
            .foregroundStyle(Color(.main))
        }
      }
      .lineLimit(1)
      .minimumScaleFactor(0.6)

      Spacer()

      HStack {
        Spacer()

        if let value = slot.value {
          Text("\(value)")
            .font(
              .system(.title2, design: .rounded)
              .bold()
            )
        } else if let target = slot.pointingTo {
          // 주소 라벨과 같은 이유로 잘리지 않고 글자 크기를 줄여 맞춘다.
          // 값 숫자에는 걸지 않는다 — 폭이 충분해 기본 크기에서 숫자가 불필요하게 작아진다
          Text("→ \(target)")
            .font(.system(.caption, design: .monospaced))
            .foregroundStyle(Color(.main))
            .fontWeight(.bold)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
        } else {
          Text("-")
            .foregroundStyle(.secondary.opacity(0.3))
        }

        Spacer()
      }

      Spacer()
    }
    .padding(12)
    .frame(height: 100)
    .background(
      RoundedRectangle(cornerRadius: 15)
        .fill(
          slot.isError ? Color(.red).opacity(0.3)
          : (slot.isHighlighted ?
             Color(.yellow).opacity(0.3) : Color(.secondarySystemGroupedBackground)
            )
        )
    )
    .overlay(alignment: .topTrailing) {
      if slot.isReferenced {
        Image(systemName: "link")
          .font(.caption)
          .fontWeight(.bold)
          .foregroundStyle(.white)
          .padding(4)
          .background(Circle().fill(Color(.main)))
          .padding(6)
          .accessibilityLabel(Text("참조됨"))
      }
    }
    // 테두리는 종류(값/포인터/빈칸)만 나타낸다. 에러는 배경 30%와 흔들림이 전달하므로
    // 여기서 빨강으로 덮으면 에러인 동안 그 칸이 값인지 포인터인지 알 수 없게 된다 (`VISUAL_LANGUAGE.md` §1)
    .overlay(
      RoundedRectangle(cornerRadius: 15)
        .stroke(
          slot.type == .pointer ? Color(.main) :
            (slot.type == .value ? Color(.green) : .clear),
          lineWidth: 2
        )
    )
    .modifier(ShakeEffect(animatableData: slot.isError ? 1 : 0))
    .animation(
      .spring(response: 0.3, dampingFraction: 0.2, blendDuration: 0),
      value: slot.isError
    )
    // 칸은 높이 100 고정 도식이라 글자만 커지면 주소·변수명·포인터 내용이 잘린다.
    // 가장 좁은 3열 칸(iPhone SE, 103.7pt)에서 실측해 잘리지 않는 상한인 xLarge로 묶는다.
    // 코드 패널·헤더·개념 카드 문장은 이 뷰 밖이라 계속 커진다
    .dynamicTypeSize(...DynamicTypeSize.xLarge)
  }
}

#Preview {
  MemorySlotView(
    slot: .init(
      address: "0x7000",
      type: .pointer,
      pointingTo: "0x7008",
      isHighlighted: true
    )
  )
}
