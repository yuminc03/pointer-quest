import SwiftUI

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
    ScrollView {
      VStack(spacing: 20) {
        // 레슨 헤더
        LessonHeaderView(lesson: vm.currentLesson)
          .padding(.horizontal)
        
        ZStack { // 화살표를 그리기 위해 ZStack 사용 (Overlay로 변경됨)
          LazyVGrid(columns: columns, spacing: 16) {
            ForEach(vm.slots) { slot in
              MemoryItem(slot: slot, vm: vm)
                .anchorPreference(key: BoundsPreferenceKey.self, value: .bounds) { anchor in
                  [slot.id: anchor]
                }
                .onTapGesture {
                  vm.handleTap(slot)
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
        }
        .padding()
      }
    }
    .navigationTitle(Text(vm.currentLesson.title))
    .background(Color(.systemGroupedBackground))
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          vm.reset()
        } label: {
          Image(systemName: "arrow.counterclockwise")
        }
      }
    }
    .safeAreaInset(edge: .bottom) {
      CodeFeedbackView(code: vm.codeLog)
        .padding()
        .background(.thinMaterial)
    }
    .alert("Lesson Complete! 🎉", isPresented: $vm.isSuccess) {
      Button("Confirm", role: .cancel) { }
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
  NavigationStack {
    MemoryGridView()
  }
}
