import SwiftUI

struct LessonHeaderView: View {
  let lesson: Lesson

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Lesson")
        .textCase(.uppercase)
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
  LessonHeaderView(lesson: LessonData.lessons[0])
}
