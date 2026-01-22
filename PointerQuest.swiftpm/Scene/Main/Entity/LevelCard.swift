import SwiftUI

/// 레벨 카드
struct LevelCard: View {
  let level: Level
  
  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      
    }
    
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

private extension LevelCard {
  var TopSection: some View {
    HStack(alignment: .firstTextBaseline) {
      Image(systemName: level.iconName)
        .resizable()
        .foregroundStyle(.white)
        .padding(10)
        .background(
          Circle().fill(Color.blue.gradient)
        )
      
      Spacer()
      
      Text("Lv. \(level.id)")
        .font(.caption)
        .fontWeight(.bold)
        .foregroundStyle(.secondary)
    }
  }
}

#Preview {
  LevelCard(level: LevelData.levels[0])
}
