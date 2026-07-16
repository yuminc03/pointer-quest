import SwiftUI

/// 레슨 카드
struct LessonCard: View {
  let lesson: Lesson
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

private extension LessonCard {
  var TopSection: some View {
    HStack(alignment: .top) {
      Image(systemName: lesson.iconName)
        .size(60)

      Spacer()

      Text("Lv. \(lesson.id)")
        .font(.title2)
    }
  }

  var Contents: some View {
    VStack(alignment: .leading, spacing: 10) {
      VStack(alignment: .leading, spacing: 0) {
        Text("Level \(lesson.id)".uppercased())

        Text(lesson.title)
      }
      .font(.title)
      .fontWeight(.bold)

      Text(lesson.description)
        .font(.body)
        .multilineTextAlignment(.leading)
    }
  }
}

#Preview {
  LessonCard(
    lesson: LessonData.lessons[0],
    colors: [Color(.main), Color(.lightBlue)]
  )
}
