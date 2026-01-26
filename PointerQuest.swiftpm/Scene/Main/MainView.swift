import SwiftUI

struct MainView: View {
  var body: some View {
    NavigationStack {
      VStack(spacing: 30) {
        Title
          .padding(.horizontal, 20)
          .padding(.top, 40)
        
        Cards
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
  
  var Cards: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      LazyHStack(spacing: 20) {
        ForEach(LevelData.levels) { level in
          NavigationLink(value: level) {
            LevelCard(level: level, color: .blue)
          }
        }
      }
      .padding()
    }
  }
}

#Preview {
  MainView()
}
