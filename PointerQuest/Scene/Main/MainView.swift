import SwiftUI

struct MainView: View {
  @State private var pageIndex = 0
  
  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        HStack(alignment: .bottom, spacing: 0) {
          Title
          
          Spacer()
          
          PageIndicator
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        
        Cards

        ContinueButton

        SandboxEntry

        Spacer()
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
  
  var PageIndicator: some View {
    HStack {
      PageControl(
        numberOfPages: LessonData.lessons.count,
        currentPage: $pageIndex
      )
      .aspectRatio(contentMode: .fit)
      .frame(height: 10)
    }
  }
  
  var Cards: some View {
    PagingCardsScrollView(
      currentPageIndex: $pageIndex,
      cards: LessonData.lessons
    )
  }

  var ContinueButton: some View {
    let lesson = LessonData.lessons[pageIndex]

    return Group {
      if lesson.isComingSoon {
        Label {
          Text("Coming Soon")
            .font(.body)
            .fontWeight(.semibold)
        } icon: {
          Image(systemName: "lock.fill")
            .size(20)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
          Capsule()
            .fill(Color.gray)
        )
      } else {
        NavigationLink(value: lesson) {
          Label {
            Text("Let's Continue")
              .font(.body)
              .fontWeight(.semibold)
          } icon: {
            Image(systemName: "paperplane.fill")
              .size(20)
          }
          .foregroundStyle(.white)
          .padding(.horizontal, 20)
          .padding(.vertical, 16)
          .background(
            Capsule()
              .fill(Color(.main))
          )
        }
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

        Spacer()

        Image(systemName: "chevron.right")
          .foregroundStyle(.tertiary)
      }
      .padding(16)
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(Color(.secondarySystemGroupedBackground))
      )
    }
    .buttonStyle(.plain)
    .padding(.horizontal, 20)
    .padding(.top, 12)
  }
}

#Preview {
  MainView()
}
