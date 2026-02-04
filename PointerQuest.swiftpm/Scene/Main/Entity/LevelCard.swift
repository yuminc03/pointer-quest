import SwiftUI

/// 레벨 카드
struct LevelCard: View {
  let level: Level
  let colors: [Color]
  
  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      TopSection
        .padding(.bottom, 30)
      
      Contents
      
      Spacer()
    }
    .foregroundStyle(.white)
    .padding(20)
    .background(
      RoundedRectangle(cornerRadius: 20)
        .fill(LinearGradient(
          gradient: .init(colors: colors),
          startPoint: .bottomLeading,
          endPoint: .topTrailing
        ))
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
  }
  
  var Contents: some View {
    VStack(alignment: .leading, spacing: 10) {
      VStack(alignment: .leading, spacing: 0) {
        Text("Level \(level.id)".uppercased())
        
        Text(level.title)
      }
      .font(.title)
      .fontWeight(.bold)
      
      Text(level.description)
        .font(.body)
        .multilineTextAlignment(.leading)
    }
  }
}

#Preview {
  LevelCard(
    level: LevelData.levels[0],
    colors: [Color(.main), Color(.lightBlue)]
  )
}
