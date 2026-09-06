import SwiftUI

/// 메모리 한 칸(`MemorySlot`)을 그리는 표시 전용 뷰
/// 드래그·드롭 같은 상호작용을 담지 않으므로 그리드 밖(개념 카드 도식 등)에서도 같은 표기로 재사용한다
struct MemorySlotView: View {
  let slot: MemorySlot

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
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
          Text("→ \(target)")
            .font(.system(.caption, design: .monospaced))
            .foregroundStyle(Color(.main))
            .fontWeight(.bold)
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
    .overlay(
      RoundedRectangle(cornerRadius: 15)
        .stroke(
          slot.isError ? Color(.red) :
            (slot.type == .pointer ? Color(.main) :
            (slot.type == .value ? Color(.green) : .clear)),
          lineWidth: 2
        )
    )
    .modifier(ShakeEffect(animatableData: slot.isError ? 1 : 0))
    .animation(
      .spring(response: 0.3, dampingFraction: 0.2, blendDuration: 0),
      value: slot.isError
    )
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
