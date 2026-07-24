import SwiftUI

/// 챕터 리스트의 레슨 한 행
struct LessonRow: View {
  let lesson: Lesson
  let colors: [Color]
  @ObservedObject private var progressStore = LessonProgressStore.shared

  var body: some View {
    HStack(spacing: 16) {
      IconChip

      VStack(alignment: .leading, spacing: 2) {
        if !lesson.isComingSoon {
          Text("Lesson \(lesson.id)")
            .font(.caption2)
            .fontWeight(.semibold)
            .textCase(.uppercase)
            .foregroundStyle(.secondary)
        }

        Text(lesson.title)
          .font(.headline)
          .foregroundStyle(.primary)

        Text(lesson.description)
          .font(.caption)
          .foregroundStyle(.secondary)
          .lineLimit(2)
      }

      Spacer(minLength: 8)

      if lesson.isComingSoon {
        Text("Coming Soon")
          .font(.caption)
          .foregroundStyle(.secondary)
      } else if progressStore.isCompleted(lesson.id) {
        Image(systemName: "checkmark.circle.fill")
          .foregroundStyle(.green)
          .accessibilityLabel(Text("Completed"))
      }
    }
    .padding(.vertical, 6)
    .opacity(lesson.isComingSoon ? 0.6 : 1)
  }
}

private extension LessonRow {
  var IconChip: some View {
    Image(systemName: lesson.iconName)
      .font(.title3)
      .foregroundStyle(.white)
      .frame(width: 44, height: 44)
      .background(
        Circle().fill(LinearGradient(
          gradient: .init(colors: lesson.isComingSoon ? [.gray, .gray.opacity(0.6)] : colors),
          startPoint: .bottomLeading,
          endPoint: .topTrailing
        ))
      )
  }
}

#Preview {
  List {
    LessonRow(
      lesson: LessonData.lessons[0],
      colors: [Color(.main), Color(.lightBlue)]
    )
  }
}
