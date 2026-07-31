import SwiftUI

/// 메모리 Grid 화면
struct MemoryGridView: View {
  @StateObject private var vm: MemoryGridVM
  /// 레슨 1 그리드 힌트를 이미 확인했는지 여부 (앱 전체에서 최초 1회만 노출)
  @AppStorage("hasSeenGridHint") private var hasSeenGridHint = false

  init(lesson: Lesson = LessonData.lessons[0]) {
    _vm = StateObject(wrappedValue: MemoryGridVM(lesson: lesson))
  }

  private let columns: [GridItem] = [
    .init(.adaptive(minimum: 100), spacing: 16)
  ]

  /// 레슨 1에 처음 진입했을 때만 그리드 힌트를 표시
  private var showGridHint: Bool {
    vm.currentLesson.id == 1 && !hasSeenGridHint
  }
  
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
              let frames = resolveFrames(from: preferences, proxy: proxy)

              ArrowDrawLayer(vm: vm, slotFrames: frames)

              // 레슨 1 전용 힌트: 소스(포인터, index 8) -> 타겟(값, index 3) 슬롯 좌표가
              // 모두 확인된 경우에만 표시
              if showGridHint,
                 vm.slots.indices.contains(8),
                 vm.slots.indices.contains(3),
                 let sourceRect = frames[vm.slots[8].id],
                 let targetRect = frames[vm.slots[3].id]
              {
                GridInteractionHintOverlay(
                  sourceRect: sourceRect,
                  targetRect: targetRect,
                  containerSize: proxy.size,
                  onDismiss: { hasSeenGridHint = true }
                )
              }
            }
          }
        }
        .padding()
      }
    }
    .navigationTitle(Text(vm.currentLesson.title))
    .background(Color(.systemGroupedBackground))
    .onChange(of: vm.slots.indices.contains(8) ? vm.slots[8].pointingTo : nil) { newValue in
      // 소스 슬롯(index 8)이 실제로 어딘가를 가리키게 되면(=첫 드래그 완료) 힌트를 자동으로 닫는다
      if newValue != nil {
        hasSeenGridHint = true
      }
    }
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
    .alert("레슨 완료! 🎉", isPresented: $vm.isSuccess) {
      Button("확인", role: .cancel) { }
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
