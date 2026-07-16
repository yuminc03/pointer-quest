# PROGRESS

세부 작업 항목은 [TODO.md](./TODO.md), 전체 방향은 [PLAN.md](./PLAN.md) 참고.

## 현재 상태

- 브랜치: `feature/lesson-data-model` — Task 1 완료 (develop 병합 대기)
- `Level` → `Lesson` 타입/파일 리네임 완료 (`LevelData` → `LessonData`, `LevelCard` → `LessonCard` 포함). 커밋마다 빌드 성공을 확인하며 5개 커밋으로 분리:
  1. Core 데이터 모델 리네임 + 임시 typealias 추가
  2. `LessonCard` 리네임
  3. `MemoryGridVM`/`MemoryGridView` 전환
  4. 남은 View 계층(`MainView`/`MissionHeaderView`/`PagingCardsScrollView`) 전환
  5. 임시 typealias 제거
- `SlotSeed`/`SuccessCondition`/`LessonBlueprint` 타입 추가 완료
- `Chapter` 타입 추가 및 기존 3레슨을 Chapter 1 "주소와 포인터"로 마이그레이션 완료 (`MemoryGridVM`은 아직 이 블루프린트를 소비하지 않고 기존 switch 로직 그대로 사용 — Task 2에서 연결 예정)

## 다음 작업

- `feature/lesson-data-model`을 `develop`에 병합할지 확인
- Task 2 (`feature/blueprint-driven-vm`): `MemoryGridVM.setupLevel`/`checkSuccess`를 블루프린트 기반 로직으로 교체
