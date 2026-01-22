import SwiftUI

struct MainView: View {
  var body: some View {
    NavigationStack {
      VStack(spacing: 30) {
        Title
          .padding(.top, 40)
        
        // 레벨 선택 그리드
        ScrollView {
          LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 150), spacing: 20)],
            spacing: 20
          ) {
            ForEach(LevelData.levels) { level in
              NavigationLink(value: level) {
                LevelCard(level: level)
              }
            }
          }
          .padding()
        }
      }
      .background(Color(.systemGroupedBackground))
      .navigationDestination(for: Level.self) { level in
        MemoryGridView(level: level)
          .navigationBarTitleDisplayMode(.inline)
      }
    }
  }
}

private extension MainView {
  var Title: some View {
    VStack(spacing: 8) {
      Text("Pointer Quest")
        .font(.system(size: 36, weight: .bold, design: .monospaced))
        .foregroundStyle(.primary)
      Text("The Memory Maze")
        .font(.title3)
        .foregroundStyle(.secondary)
    }
  }
}

#Preview {
  MainView()
}
