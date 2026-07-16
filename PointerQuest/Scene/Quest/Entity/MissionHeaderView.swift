import SwiftUI

struct MissionHeaderView: View {
  let lesson: Lesson

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Mission".uppercased())
        .font(.caption)
        .fontWeight(.bold)
        .foregroundStyle(.secondary)

      Text(lesson.description)
        .font(.body)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
  }
}

#Preview {
  MissionHeaderView(lesson: .init(
    id: 0,
    title: "Title",
    description: "Description",
    iconName: "swift"
  ))
}
