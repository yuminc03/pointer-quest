import SwiftUI

/// 카드 스크롤 View
struct PagingCardsScrollView: View {
  @State private var currentScrollOffset: CGFloat = 0
  @Binding var currentPageIndex: Int
  
  let cards: [Level]
  private let scrollDampingFactor: CGFloat = 0.6
    
  /// 화면 너비
  var screenWidth: CGFloat {
    return UIScreen.main.bounds.width
  }
  
  /// 카드 너비
  var cardWidth: CGFloat {
    return screenWidth - 100
  }
  
  /// 카드 높이
  var cardHieght: CGFloat {
    return (cardWidth / 2.5) * 3.5
  }
  
  /// 카드 여백 (카드 사이 간격)
  var cardPadding: CGFloat {
    return 20
  }
  
  /// 처음 scroll view 시작점 위치
  /// 카드가 가운데 오도록 필요
  /// 카드 여백 + ((화면너비 - 카드너비) / 2)
  var initialOffset: CGFloat {
    return (screenWidth - cardWidth) / 2
  }
  
  var body: some View {
    GeometryReader { proxy in
      LazyHStack(alignment: .center, spacing: cardPadding) {
        ForEach(cards) { card in
          LevelCard(level: card, color: .blue)
            .frame(width: cardWidth, height: cardHieght)
        }
      }
    }
    .frame(width: screenWidth)
    .offset(x: currentScrollOffset, y: 0)
    .onAppear {
      currentScrollOffset = pagingOffset(for: currentPageIndex)
    }
    .simultaneousGesture(
      DragGesture(minimumDistance: 1, coordinateSpace: .global)
        .onChanged { value in
          dragOffset = value.translation.width
          currentScrollOffset = getCurrentScrollOffset()
        }
        .onEnded { value in
          // 손가락으로 튕긴 거리(velocity) 예측값
          let offset = value.predictedEndTranslation.width - dragOffset
          // 너무 휙 넘어가지 않게 감속 (0.6배)
          let velocityDiff = offset * scrollDampingFactor
          // 현재 위치 + 관성 이동 거리를 합쳐서 최종적으로 도달할 페이지 계산
          var newPageIndex = currentPage(for: currentScrollOffset + velocityDiff)
          let currentItemOffset = CGFloat(currentPageIndex) * (cardWidth + cardPadding)
          
          if currentScrollOffset < -currentItemOffset
             && newPageIndex == currentPageIndex
          {
            newPageIndex += 1
          }
          
          dragOffset = 0
          
          // 애니메이션과 함께 해당 페이지 위치로 이동
          withAnimation(.interpolatingSpring(
            mass: 0.1,
            stiffness: 20,
            damping: 1.5,
            initialVelocity: 0
          )) {
            currentPageIndex = newPageIndex
            currentScrollOffset = getCurrentScrollOffset()
          }
        }
    )
    .contentShape(Rectangle())
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
    
  /// 현재 보여주어야 할 스크롤 위치 실시간 계산
  private func getCurrentScrollOffset() -> CGFloat {
    return pagingOffset(for: currentPageIndex) + dragOffset
  }
}

#Preview {
  PagingCardsScrollView(
    currentPageIndex: .constant(0),
    cards: LevelData.levels
  )
}
