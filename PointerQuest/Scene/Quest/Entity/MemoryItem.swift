import SwiftUI

/// 메모리 Grid Item
/// 칸의 표기는 `MemorySlotView`가 그리고, 여기서는 그리드에서만 필요한 드래그·드롭을 얹는다
struct MemoryItem: View {
  let slot: MemorySlot
  @ObservedObject var vm: MemoryGridVM

  var body: some View {
    MemorySlotView(slot: slot)
      .draggable(slot.address)
      .dropDestination(for: String.self) { droppedAddresses, location in
        guard let draggedAddress = droppedAddresses.first
        else { return false }

        // 자기 자신에게 drag한 것이 아닐 때
        if draggedAddress != slot.address {
          vm.handleDrop(
            sourceAddress: draggedAddress,
            destinationAddress: slot.address
          )

          return true
        }

        return false
      }
      .shadow(
        color: .black.opacity(0.05),
        radius: 5,
        x: 0,
        y: 2
      )
  }
}

#Preview {
  MemoryItem(
    slot: .init(
      address: "0x7000",
      type: .pointer,
      pointingTo: "0x7008",
      isHighlighted: true),
    vm: .init()
  )
}
