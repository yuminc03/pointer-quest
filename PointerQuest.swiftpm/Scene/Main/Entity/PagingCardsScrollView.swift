import SwiftUI

/// 카드 스크롤 View
struct PagingCardsScrollView: View {
  @State private var currentScrollOffset: CGFloat = 0
  @Binding var currentPage: Int
  
  let cards: [Level]
    
  /// 화면 너비
  var screenWidth: CGFloat {
    return UIScreen.main.bounds.width
  }
  
  /// 카드 너비
  var cardWidth: CGFloat {
    return screenWidth - 120
  }
  
  /// 카드 여백 (카드 사이 간격)
  var cardPadding: CGFloat {
    return 20
  }
  
  /// 처음 scroll view 시작점 위치
  /// 카드가 가운데 오도록 필요
  /// 카드 여백 + ((화면너비 - 카드너비) / 2)
  var initialOffset: CGFloat {
    return cardPadding + ((screenWidth - cardWidth) / 2)
  }
  
  var body: some View {
    GeometryReader { proxy in
      LazyHStack(alignment: .center, spacing: cardPadding) {
        ForEach(cards) { card in
          LevelCard(level: card, color: .blue)
            .frame(width: cardWidth)
        }
      }
    }
    .frame(width: screenWidth)
    .offset(x: currentScrollOffset, y: 0)
    .onAppear {
      currentScrollOffset = pagingOffset(for: currentPage)
    }
  }
  
  /// 페이지 이동시 움직여야할 양
  /// index 번째 카드를 중앙에 놓기 위해 이동할 양
  private func pagingOffset(for pageIndex: Int) -> CGFloat {
    // 이동해야 할 거리 = index * (카드너비 + 카드 여백)
    let offset = CGFloat(pageIndex) * (cardWidth + cardPadding)
    
    // 카드를 왼쪽으로 밀면서 오른쪽 카드를 봐야해서 offset을 - 해야함
    return initialOffset - offset
  }
  
  /// 현재 페이지
  private func currentPage(for offset: CGFloat) -> Int {
    // 이동한 논리적 거리
    // offset이 작아질수록(왼쪽 이동) 논리적 거리는 커져야 하므로 -1을 곱함
    let logicalOffset = (offset - initialOffset) * -1.0
    
    // 대략적인 페이지 번호(실수) = (이동한 거리) / (카드 1개 크기)
    let index = logicalOffset / (cardWidth + cardPadding)
    
    return Int(round(index))
  }
}

#Preview {
  PagingCardsScrollView(
    currentPage: .constant(0),
    cards: LevelData.levels
  )
}
