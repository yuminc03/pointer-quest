# PROGRESS

세부 작업 항목은 [TODO.md](./TODO.md), 전체 방향은 [PLAN.md](./PLAN.md) 참고.

## 현재 상태

- `feature/lesson-data-model` (Task 1)은 `develop`에 병합 완료
- 브랜치: `feature/blueprint-driven-vm` — Task 2 작업 중
- `Level` → `Lesson` 타입/파일 리네임, `SlotSeed`/`SuccessCondition`/`LessonBlueprint`/`Chapter` 타입 추가, 기존 3레슨의 Chapter 1 마이그레이션은 Task 1에서 완료
- `MemoryGridVM.setupLevel`을 `Lesson.blueprint.seeds` 기반 범용 로직으로 교체 완료 (`switch level.id` 제거, `SlotSeed`를 순회하며 슬롯 배치)
- `MemoryGridVM.checkSuccess`를 `Lesson.blueprint.successCondition` 기반 범용 로직으로 교체 완료 (`switch currentLesson.id` 제거, `.anyPointerPointsTo`/`.chain` case 처리)
- `handleDrop`의 잠금 슬롯 체크도 `currentLesson.id == 2` 하드코딩 대신 `slots[targetIndex].isLocked` 범용 체크로 변경
- 사용하지 않던 `initializeMemory()` 죽은 코드 제거
- 빌드 성공 확인 (`xcodebuild ... build` → BUILD SUCCEEDED). 기존 3레슨 동작 동일성은 별도 검증 진행 중

## 다음 작업

- Task 2 동작 검증 결과 확인 후 커밋 메시지 제안 및 커밋
- Task 2 완료 후 `develop` 병합 여부 확인
- Task 3 (`feature/learning-tone-copy`): 게임 카피 → 학습 도구 카피 전환
