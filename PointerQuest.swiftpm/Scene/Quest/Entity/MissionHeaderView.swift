import SwiftUI

struct MissionHeaderView: View {
  let level: Level
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Mission".uppercased())
        .font(.caption)
        .fontWeight(.bold)
        .foregroundStyle(.secondary)
      
      Text(level.description)
        .font(.body)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
  }
}

#Preview {
  MissionHeaderView(level: .init(
    id: 0,
    title: "Title",
    description: "Description",
    iconName: "swift"
  ))
}
