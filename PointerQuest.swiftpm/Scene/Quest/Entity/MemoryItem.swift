import SwiftUI

/// 메모리 Grid Item
struct MemoryItem: View {
  let slot: MemorySlot
  @ObservedObject var vm: MemoryGridVM
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(slot.address)
        .font(.system(.caption, design: .monospaced))
        .foregroundStyle(.secondary)
      
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
          Text(target)
            .font(.system(.caption, design: .monospaced))
            .foregroundStyle(.blue)
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
          slot.isError ? Color.red.opacity(0.3)
          : (slot.isHighlighted ?
             Color.yellow.opacity(0.3) : Color(.secondarySystemGroupedBackground)
            )
        )
        .overlay(
          slot.isError ? .red.opacity(0.2) : (slot.isHighlighted ? .yellow.opacity(0.2) : .clear),
          in: RoundedRectangle(cornerRadius: 15)
        )
    )
    .overlay(
    Group {
        if slot.isLocked {
          Image(systemName: "lock.fill")
            .font(.largeTitle)
            .foregroundStyle(.gray.opacity(0.3))
        }
      }
    )
    .overlay(
      RoundedRectangle(cornerRadius: 15)
        .stroke(
          slot.isError ? .red :
            (slot.type == .pointer ? .blue :
              (slot.type == .value ? .green : .clear)),
          lineWidth: 2
        )
    )
    .modifier(ShakeEffect(animatableData: slot.isError ? 1 : 0))
    .animation(
      .spring(response: 0.3, dampingFraction: 0.2, blendDuration: 0),
      value: slot.isError
    )
    .draggable(slot.address)
    .dropDestination(for: String.self) { droppedAddresses, location in
      guard let draggedAddress = droppedAddresses.first
      else { return false }
      
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
