import SwiftUI

/// 레벨 카드
struct LevelCard: View {
  let level: Level
  let color: Color
  
  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      TopSection
        .padding(.bottom, 30)
      
      Contents
      
      Spacer()
    }
    .padding(20)
    .background(
      RoundedRectangle(cornerRadius: 20)
        .fill(color)
        .shadow(
          color: .black.opacity(0.3),
          radius: 15, x: 0, y: 10
        )
    )
  }
}

private extension LevelCard {
  var TopSection: some View {
    HStack(alignment: .top) {
      Image(systemName: level.iconName)
        .size(60)
      
      Spacer()
      
      Text("Lv. \(level.id)")
        .font(.title2)
    }
    .foregroundStyle(.white)
  }
  
  var Contents: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(level.title)
        .font(.title)
        .fontWeight(.bold)
        .lineLimit(1)
      
      Text(level.description)
        .font(.body)
        .multilineTextAlignment(.leading)
    }
    .foregroundStyle(.white)
  }
}

#Preview {
  LevelCard(level: LevelData.levels[0], color: .purple)
}
