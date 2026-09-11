import SwiftUI

struct LessonHeaderView: View {
  let lesson: Lesson

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(sectionLabel)
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

  /// 샌드박스 모드는 "Lesson" 대신 "Playground" 라벨을 보여준다
  private var sectionLabel: LocalizedStringResource {
    lesson.blueprint.successCondition == .sandbox ? "플레이그라운드" : "레슨"
  }
}

#Preview {
  LessonHeaderView(lesson: LessonData.lessons[0])
}
