import SwiftUI

struct MainMenuView: View {
  var body: some View {
    NavigationStack {
      VStack(spacing: 30) {
        // 타이틀 영역
        VStack(spacing: 8) {
          Text("Pointer Quest")
            .font(.system(size: 36, weight: .bold, design: .monospaced))
            .foregroundStyle(.primary)
          Text("The Memory Maze")
            .font(.title3)
            .foregroundStyle(.secondary)
        }
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

// 레벨 카드 뷰
struct LevelCard: View {
  let level: Level
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Image(systemName: level.iconName)
          .font(.title)
          .foregroundStyle(.white)
          .padding(10)
          .background(Circle().fill(Color.blue.gradient))
        
        Spacer()
        
        Text("Lv.\(level.id)")
          .font(.caption)
          .fontWeight(.bold)
          .foregroundStyle(.secondary)
      }
      
      VStack(alignment: .leading, spacing: 4) {
        Text(level.title)
          .font(.headline)
          .foregroundStyle(.primary)
          .lineLimit(1)
        
        Text(level.description)
          .font(.caption)
          .foregroundStyle(.secondary)
          .lineLimit(2)
          .multilineTextAlignment(.leading)
      }
    }
    .padding()
    .background(Color(.secondarySystemGroupedBackground))
    .cornerRadius(16)
    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
  }
}

#Preview {
  MainMenuView()
}
