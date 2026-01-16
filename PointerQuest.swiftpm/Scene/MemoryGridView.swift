import SwiftUI

/// 메모리 Grid 화면
struct MemoryGridView: View {
  @StateObject private var vm = MemoryGridVM()
  @State private var slotFrames: [UUID: CGRect] = [:] // 각 셀의 위치 정보 저장
  
  private let columns: [GridItem] = [
    .init(.adaptive(minimum: 100), spacing: 16)
  ]
  
  var body: some View {
    NavigationStack {
      ScrollView {
        ZStack { // 화살표를 그리기 위해 ZStack 사용
          LazyVGrid(columns: columns, spacing: 16) {
            ForEach(vm.slots) { slot in
              MemoryItem(slot: slot, vm: vm)
                .background(
                  GeometryReader { geo in
                    Color.clear
                      .preference(
                        key: BoundsPreferenceKey.self,
                        value: [slot.id: geo.frame(in: .named("gridSpace"))] // 좌표공간 통일
                      )
                  }
                )
                .onTapGesture {
                  print("클릭된 메모리 주소: \(slot.address)")
                }
              // 더블 탭 시 역참조(Dereference) 실행
                .simultaneousGesture(
                  TapGesture(count: 2).onEnded {
                    vm.dereference(pointerAddr: slot.address)
                  }
                )
            }
          }
          .coordinateSpace(name: "gridSpace") // 좌표계 이름 설정
          .onPreferenceChange(BoundsPreferenceKey.self) { preferences in
            self.slotFrames = preferences // 하위 뷰들의 위치 정보 수집 완료
          }
          
          // 화살표 그리기 레이어
          ArrowDrawLayer(vm: vm, slotFrames: slotFrames)
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
}

#Preview {
  MemoryGridView()
}
