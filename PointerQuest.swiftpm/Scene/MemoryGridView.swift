import SwiftUI

/// 메모리 Grid 화면
struct MemoryGridView: View {
  @StateObject private var vm = MemoryGridVM()
  
  private let columns: [GridItem] = [
    .init(.adaptive(minimum: 100), spacing: 16)
  ]
  
  var body: some View {
    NavigationStack {
      ScrollView {
        LazyVGrid(columns: columns, spacing: 16) {
          ForEach(vm.slots) { slot in
            MemoryItem(slot: slot, vm: vm)
              .onTapGesture {
                print("클릭된 메모리 주소: \(slot.address)")
              }
          }
        }
        .padding()
      }
      .navigationTitle("Pointer Visualizer")
      .background(Color(.systemGroupedBackground))
    }
  }
}

#Preview {
  MemoryGridView()
}
