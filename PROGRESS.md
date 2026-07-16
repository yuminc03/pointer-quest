# PROGRESS

세부 작업 항목은 [TODO.md](./TODO.md), 전체 방향은 [PLAN.md](./PLAN.md) 참고.

## 현재 상태

- 브랜치: `feature/lesson-data-model` (Task 1 진행 중)
- `Level` → `Lesson` 타입/파일 리네임 완료 (`LevelData` → `LessonData`, `LevelCard` → `LessonCard` 포함). 커밋마다 빌드 성공을 확인하며 5개 커밋으로 분리 완료:
  1. Core 데이터 모델 리네임 + 임시 typealias 추가
  2. `LessonCard` 리네임
  3. `MemoryGridVM`/`MemoryGridView` 전환
  4. 남은 View 계층(`MainView`/`MissionHeaderView`/`PagingCardsScrollView`) 전환
  5. 임시 typealias 제거
- `LessonBlueprint`/`SuccessCondition`/`Chapter` 타입은 아직 미착수

## 다음 작업

- Task 1 남은 항목(블루프린트 타입, Chapter 타입, 3레벨 데이터 마이그레이션) 진행
