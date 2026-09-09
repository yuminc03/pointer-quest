import SwiftUI

struct MainView: View {
  /// 현재 열려 있는 레슨 스택
  /// 완료 알럿의 "다음 레슨"이 마지막 원소를 교체하는 방식으로 이동하기 때문에,
  /// 레슨을 몇 개나 이어서 풀어도 뒤로가기 한 번이면 이 목록으로 돌아온다
  @State private var path = [Lesson]()

  /// 챕터 아이콘 칩의 그라데이션
  ///
  /// 챕터마다 다른 색을 주면 그 색이 `Green`(값)·`Red`(에러)와 겹쳐, 목록 화면의 장식이
  /// 그리드 화면의 종류·상태와 같은 색을 쓰게 된다. 챕터 구분은 색이 아니라 심볼이 한다
  private let chapterIconColors = [Color(.main), Color(.lightBlue)]

  var body: some View {
    NavigationStack(path: $path) {
      VStack(spacing: 0) {
        Title
          .padding(.horizontal, 20)
          .padding(.top, 20)
          .padding(.bottom, 8)

        List {
          ForEach(LessonData.chapters) { chapter in
            Section {
              ForEach(chapter.lessons) { lesson in
                lessonRow(lesson: lesson, colors: chapterIconColors)
              }
            } header: {
              Text("챕터 \(chapter.id)") + Text(" · ") + Text(chapter.title)
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
        MemoryGridView(lesson: lesson, path: $path)
          .navigationBarTitleDisplayMode(.inline)
          // "다음 레슨"은 스택의 마지막 원소를 교체하므로 화면 위치가 그대로다.
          // id를 주지 않으면 SwiftUI가 같은 뷰로 보고 @StateObject를 유지해
          // init이 다시 불리지 않는다 — 레슨을 바꿔도 이전 레슨의 VM이 남는다
          .id(lesson.id)
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

      Text("메모리의 미로")
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
              colors: [Color(.deco), Color(.lightDeco)],
              startPoint: .bottomLeading,
              endPoint: .topTrailing
            ))
          )

        VStack(alignment: .leading, spacing: 2) {
          Text(LessonData.sandboxLesson.title)
            .font(.headline)
            .foregroundStyle(.primary)

          Text("목표 없이 자유롭게 탐험해 보세요.")
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
