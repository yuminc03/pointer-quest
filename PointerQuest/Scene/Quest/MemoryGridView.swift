import SwiftUI

/// 메모리 Grid 화면
struct MemoryGridView: View {
  @StateObject private var vm: MemoryGridVM
  /// 레슨 1 그리드 힌트를 이미 확인했는지 여부 (앱 전체에서 최초 1회만 노출)
  @AppStorage("hasSeenGridHint") private var hasSeenGridHint = false
  @State private var isConceptCardPresented = false
  /// `MainView`가 들고 있는 레슨 스택
  /// "다음 레슨"으로 이동할 때 마지막 원소를 교체하는 데만 쓴다
  @Binding private var path: [Lesson]

  init(
    lesson: Lesson = LessonData.lessons[0],
    path: Binding<[Lesson]> = .constant([])
  ) {
    _vm = StateObject(wrappedValue: MemoryGridVM(lesson: lesson))
    _path = path
  }

  private let columns: [GridItem] = [
    .init(.adaptive(minimum: 100), spacing: 16)
  ]

  /// 레슨 1에 처음 진입했을 때만 그리드 힌트를 표시
  private var showGridHint: Bool {
    vm.currentLesson.id == 1 && !hasSeenGridHint
  }

  /// 이어서 풀 수 있는 다음 레슨. 없으면 완료 알럿에 "다음 레슨" 버튼을 그리지 않는다
  private var nextLesson: Lesson? {
    LessonData.nextLesson(after: vm.currentLesson)
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
      if vm.currentLesson.conceptCard != nil {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            isConceptCardPresented = true
          } label: {
            Image(systemName: "info.circle")
          }
        }
      }
      if vm.currentLesson.blueprint.hintCode != nil {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            vm.showHint()
          } label: {
            Image(systemName: "lightbulb")
          }
        }
      }
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

      if let nextLesson {
        Button("다음 레슨") {
          moveToNextLesson(nextLesson)
        }
      }
    } message: {
      // 요약이 없는 레슨(샌드박스·Coming Soon)에서는 본문 없이 제목만 나온다
      if let summary = vm.currentLesson.summary {
        if let chapterId = LessonData.chapter(of: vm.currentLesson)?.id, nextLesson == nil {
          // 이어서 풀 레슨이 없으면 여기서 챕터가 끝난다는 것을 함께 알린다
          // 줄바꿈은 번역 대상이 아니므로 verbatim으로 두어 카탈로그에 키가 생기지 않게 한다
          Text(summary) + Text(verbatim: "\n\n") + Text("여기까지가 챕터 \(chapterId)입니다.")
        } else {
          Text(summary)
        }
      }
    }
    .sheet(isPresented: $isConceptCardPresented) {
      if let conceptCard = vm.currentLesson.conceptCard {
        ConceptCardView(
          title: vm.currentLesson.title,
          card: conceptCard,
          isPresented: $isConceptCardPresented
        )
      }
    }
    .onAppear {
      presentConceptCardIfNeeded()
    }
  }

  /// 개념 카드가 있는 레슨에 처음 들어왔을 때만 카드를 자동으로 띄운다.
  /// 재진입 시에는 뜨지 않으며, 그때는 툴바의 `(i)` 버튼으로 다시 연다
  private func presentConceptCardIfNeeded() {
    let lessonId = vm.currentLesson.id
    guard vm.currentLesson.conceptCard != nil,
          !LessonProgressStore.shared.hasSeenConceptCard(lessonId)
    else { return }

    LessonProgressStore.shared.markConceptCardSeen(lessonId)
    isConceptCardPresented = true
  }

  /// 스택의 마지막 원소를 교체해 다음 레슨으로 넘어간다.
  /// 새 화면을 쌓지 않으므로 몇 개를 이어서 풀어도 뒤로가기 한 번이면 레슨 목록으로 돌아온다
  private func moveToNextLesson(_ lesson: Lesson) {
    guard !path.isEmpty else { return }

    path[path.count - 1] = lesson
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
