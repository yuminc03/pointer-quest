import SwiftUI

struct MainView: View {
  @State private var pageIndex = 0
  
  var body: some View {
    NavigationStack {
      VStack(spacing: 30) {
        Title
          .padding(.horizontal, 20)
          .padding(.top, 40)
        
        Cards
        
        PageIndicator
          .padding(.bottom, 40)
        
        ContinueButton
      }
      .background(Color(.systemGroupedBackground))
      .navigationDestination(for: Level.self) { level in
        MemoryGridView(level: level)
          .navigationBarTitleDisplayMode(.inline)
      }
    }
  }
}

private extension MainView {
  var Title: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Pointer Quest")
        .font(.system(size: 36, weight: .bold))
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
        numberOfPages: LevelData.levels.count,
        currentPage: $pageIndex
      )
      .aspectRatio(contentMode: .fit)
      .frame(width: 90, height: 10)
    }
  }
  
  var Cards: some View {
    PagingCardsScrollView(
      currentPageIndex: $pageIndex,
      cards: LevelData.levels
    )
  }
  
  var ContinueButton: some View {
    Button {
      
    } label: {
      HStack(spacing: 10) {
        Image(systemName: "paperplane.fill")
          .size(20)
        
        Text("Let's Continue")
          .font(.system(size: 16, weight: .semibold))
      }
      .foregroundStyle(.white)
      .padding(.horizontal, 20)
      .padding(.vertical, 16)
      .background(
        Capsule()
          .fill(.blue)
      )
    }
  }
}

#Preview {
  MainView()
}
