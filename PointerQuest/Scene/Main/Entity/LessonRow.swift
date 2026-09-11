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
          Text("레슨 \(lesson.id)")
            .font(.caption2)
            .fontWeight(.semibold)
            .textCase(.uppercase)
            .foregroundStyle(.secondary)
        }

        Text(lesson.title)
          .font(.headline)
          .foregroundStyle(.primary)

        Text(descriptionSummary)
          .font(.caption)
          .foregroundStyle(.secondary)
          .lineLimit(2)
      }

      Spacer(minLength: 8)

      if lesson.isComingSoon {
        Text("준비 중")
          .font(.caption)
          .foregroundStyle(.secondary)
      } else if progressStore.isCompleted(lesson.id) {
        Image(systemName: "checkmark.circle.fill")
          .foregroundStyle(Color(.green))
          .accessibilityLabel(Text("완료"))
      }
    }
    .padding(.vertical, 6)
    .opacity(lesson.isComingSoon ? 0.6 : 1)
  }
}

private extension LessonRow {
  /// 목록 행에 보여줄 설명의 첫 문장
  ///
  /// `description`은 "한 줄 요약\n조작 안내" 두 문장을 묶은 한 덩어리다. 목록은 레슨을 고르는
  /// 화면이므로 요약만 두고, 조작 안내는 레슨에 들어가면 `LessonHeaderView`가 전문으로 보여준다.
  /// 줄 수 제한만으로 자르면 한국어(문장당 한 줄)에는 맞고 영어(문장당 두 줄)에서는
  /// 두 번째 문장이 통째로 사라진다 — 언어마다 다른 줄 수에 기대지 않기 위해 문장 단위로 자른다
  var descriptionSummary: String {
    let description = String(localized: lesson.description)
    return description.components(separatedBy: "\n").first ?? description
  }

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
