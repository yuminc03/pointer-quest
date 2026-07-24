import SwiftUI

struct MainView: View {
  private let chapterColorPalette: [[Color]] = [
    [Color(.main), Color(.lightBlue)],
    [Color(.green), Color(.lightGreen)],
    [Color(.red), Color(.lightRed)],
  ]

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        Title
          .padding(.horizontal, 20)
          .padding(.top, 20)
          .padding(.bottom, 8)

        List {
          ForEach(Array(LessonData.chapters.enumerated()), id: \.element.id) { index, chapter in
            Section {
              ForEach(chapter.lessons) { lesson in
                lessonRow(lesson: lesson, colors: chapterColorPalette[index % chapterColorPalette.count])
              }
            } header: {
              Text("Chapter \(chapter.id)") + Text(" · ") + Text(chapter.title)
            }
          }

          Section {
            SandboxEntry
          }
        }
        .listStyle(.insetGrouped)
      }
      .background(Color(.systemGroupedBackground))
      .navigationDestination(for: Lesson.self) { lesson in
        MemoryGridView(lesson: lesson)
          .navigationBarTitleDisplayMode(.inline)
      }
    }
  }
}

private extension MainView {
  var Title: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Pointer Quest")
        .font(.largeTitle)
        .fontWeight(.bold)
        .foregroundStyle(.primary)

      Text("The Memory Maze")
        .font(.title3)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  @ViewBuilder
  func lessonRow(lesson: Lesson, colors: [Color]) -> some View {
    if lesson.isComingSoon {
      LessonRow(lesson: lesson, colors: colors)
    } else {
      NavigationLink(value: lesson) {
        LessonRow(lesson: lesson, colors: colors)
      }
    }
  }

  var SandboxEntry: some View {
    NavigationLink(value: LessonData.sandboxLesson) {
      HStack(spacing: 16) {
        Image(systemName: LessonData.sandboxLesson.iconName)
          .font(.title2)
          .foregroundStyle(.white)
          .frame(width: 44, height: 44)
          .background(
            Circle().fill(LinearGradient(
              colors: [Color(.yellow), Color(.lightYellow)],
              startPoint: .bottomLeading,
              endPoint: .topTrailing
            ))
          )

        VStack(alignment: .leading, spacing: 2) {
          Text(LessonData.sandboxLesson.title)
            .font(.headline)
            .foregroundStyle(.primary)

          Text("No objective. Just explore.")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
      .padding(.vertical, 6)
    }
  }
}

#Preview {
  MainView()
}
