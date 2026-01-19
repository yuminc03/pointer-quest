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
              .anchorPreference(key: BoundsPreferenceKey.self, value: .bounds) { anchor in
                [slot.id: anchor]
              }
              .onTapGesture {
                print("클릭된 메모리 주소: \(slot.address)")
              }
              .simultaneousGesture(
                // 더블 탭 시 역참조(Dereference) 실행
                TapGesture(count: 2).onEnded {
                  vm.dereference(pointerAddr: slot.address)
                }
              )
          }
        }
        // overlayPreferenceValue를 사용하면 GeometryProxy를 통해 Anchor를 좌표로 변환 가능
        .overlayPreferenceValue(BoundsPreferenceKey.self) { preferences in
          GeometryReader { proxy in
            ArrowDrawLayer(
              vm: vm,
              slotFrames: resolveFrames(from: preferences, proxy: proxy)
            )
          }
        }
        .padding()
      }
      .navigationTitle("Pointer Visualizer")
      .background(Color(.systemGroupedBackground))
      .safeAreaInset(edge: .bottom) {
        CodeFeedbackView(code: vm.codeLog)
          .padding()
          .background(.thinMaterial)
      }
    }
  }
  
  // Anchor를 CGRect로 변환하는 헬퍼 함수
  private func resolveFrames(
    from preferences: [UUID: Anchor<CGRect>],
    proxy: GeometryProxy
  ) -> [UUID: CGRect] {
    var frames: [UUID: CGRect] = [:]
    for (id, anchor) in preferences {
      frames[id] = proxy[anchor]
    }
    return frames
  }
}

#Preview {
  MemoryGridView()
}
