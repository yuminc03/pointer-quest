import SwiftUI

/// 레슨이 전제하는 개념을 그리드에 들어가기 전에 설명하는 카드 시트
/// 도식은 새 그림이 아니라 그리드와 같은 `MemorySlotView`/`PointerArrow`로 조립한다 (`VISUAL_LANGUAGE.md` §8)
struct ConceptCardView: View {
  let title: LocalizedStringResource
  let card: ConceptCard
  @Binding var isPresented: Bool

  var body: some View {
    VStack(spacing: 20) {
      CapsuleView
        .padding(.top, 20)

      ScrollView(.vertical) {
        VStack(alignment: .leading, spacing: 24) {
          Title

          DiagramSection

          Sentences
        }
        .padding(.horizontal, 20)
      }

      StartButton
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
  }
}

private extension ConceptCardView {
  var CapsuleView: some View {
    Rectangle()
      .frame(width: 40, height: 5)
      .foregroundColor(Color(.lightGray).opacity(0.3))
      .clipShape(Capsule())
  }

  var Title: some View {
    Text(title)
      .font(.title)
      .fontWeight(.bold)
      .frame(maxWidth: .infinity, alignment: .leading)
  }

  var Sentences: some View {
    VStack(alignment: .leading, spacing: 12) {
      ForEach(Array(card.sentences.enumerated()), id: \.offset) { _, sentence in
        Text(sentence)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
    .font(.body)
  }

  var StartButton: some View {
    Button {
      isPresented = false
    } label: {
      Text("시작하기")
        .foregroundStyle(.white)
        .font(.body)
        .fontWeight(.bold)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(
          Capsule()
            .fill(Color(.main))
        )
    }
  }

  /// 도식에 쓰는 주소·변수명은 해당 레슨의 그리드와 코드 패널에 실제로 등장하는 값을 그대로 쓴다
  @ViewBuilder
  var DiagramSection: some View {
    switch card.diagram {
    case .pointerToValue:
      // 레슨 1: 포인터 p1(0x7020)이 값 target(0x700C)을 가리킨다
      diagram(
        slots: [
          .init(address: "0x7020", type: .pointer, pointingTo: "0x700C", variableName: "p1"),
          .init(address: "0x700C", value: 100, type: .value, variableName: "target")
        ],
        columns: 2,
        slotWidth: 110
      )

    case .pointerToPointer:
      // 레슨 2: 이중 포인터 p1(0x7038) -> 포인터 ptr1(0x7014) -> 값 target(0x701C)
      diagram(
        slots: [
          .init(address: "0x7038", type: .pointer, pointingTo: "0x7014", variableName: "p1"),
          .init(
            address: "0x7014",
            type: .pointer,
            pointingTo: "0x701C",
            isReferenced: true,
            variableName: "ptr1"
          ),
          .init(address: "0x701C", value: 777, type: .value, variableName: "target")
        ],
        columns: 3,
        slotWidth: 84
      )

    case .pointerChain:
      // 레슨 3: start -> nodeA -> nodeB -> treasure. 한 줄에 넣으면 칸이 너무 좁아져 2행으로 배치한다
      diagram(
        slots: [
          .init(address: "0x7000", type: .pointer, pointingTo: "0x7014", variableName: "start"),
          .init(address: "0x7014", type: .pointer, pointingTo: "0x702C", variableName: "nodeA"),
          .init(address: "0x702C", type: .pointer, pointingTo: "0x703C", variableName: "nodeB"),
          .init(address: "0x703C", value: 999, type: .value, variableName: "treasure")
        ],
        columns: 2,
        slotWidth: 110
      )
    }
  }

  /// 슬롯들을 격자로 배치하고, 포인터가 가리키는 관계를 화살표로 겹쳐 그린다.
  /// 화살표 좌표는 그리드 화면과 같은 방식(`BoundsPreferenceKey` + `overlayPreferenceValue`)으로 실제 배치에서 얻는다
  func diagram(
    slots: [MemorySlot],
    columns: Int,
    slotWidth: CGFloat
  ) -> some View {
    LazyVGrid(
      columns: Array(repeating: GridItem(.fixed(slotWidth), spacing: 24), count: columns),
      spacing: 24
    ) {
      ForEach(slots) { slot in
        MemorySlotView(slot: slot)
          .anchorPreference(key: BoundsPreferenceKey.self, value: .bounds) { anchor in
            [slot.id: anchor]
          }
      }
    }
    .frame(maxWidth: .infinity)
    .overlayPreferenceValue(BoundsPreferenceKey.self) { preferences in
      GeometryReader { proxy in
        ForEach(slots) { slot in
          if slot.type == .pointer,
             let targetAddress = slot.pointingTo,
             let targetSlot = slots.first(where: { $0.address == targetAddress }),
             let startAnchor = preferences[slot.id],
             let endAnchor = preferences[targetSlot.id]
          {
            let startRect = proxy[startAnchor]
            let endRect = proxy[endAnchor]

            PointerArrow(
              startPoint: .init(x: startRect.midX, y: startRect.midY),
              endPoint: .init(x: endRect.midX, y: endRect.midY)
            )
          }
        }
      }
    }
  }
}

#Preview {
  let lesson = LessonData.lessons[2]

  if let conceptCard = lesson.conceptCard {
    ConceptCardView(
      title: lesson.title,
      card: conceptCard,
      isPresented: .constant(true)
    )
  }
}
