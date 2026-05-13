# Roadmap

이 문서는 `ywc-task-generator` skill 의 현 상태와, 앞으로 실사용 이후 착수할 개선 항목을 정리합니다. Skill 동작에 직접 영향을 주지 않는 meta 문서이며, runtime 에 loading 되지 않습니다.

## 현재 상태 (2026-04 기준)

| 영역 | 상태 |
|---|---|
| Naming convention | **6-digit PHASE + 3-digit SEQUENCE** (`000001-010-db-create-user-table`) |
| Granularity Mode | `human` / `llm` 이중 mode, Step 5 에서 사용자 확인 필수 (silent default 없음) |
| Safety Invariants | DB migration 분리, Library 도입 분리, Phase hard gate, post-task buildability |
| Static validation | `tools/scripts/run_task_generator_evals.py --bundle yw_claude` |
| Pre-commit hook | `.pre-commit-config.yaml` 존재, 개별 clone 에서 `pre-commit install` 로 opt-in |
| Output 품질 회귀 탐지 | 현재 미지원 — manual review 에 의존 |

## Tier 3 — LLM-judge 기반 Output 회귀 Runner

### 목표

현재 runner 는 skill bundle 의 **구조적 계약** (marker 존재, eval schema, file 존재) 만 검증합니다. 실제 skill 을 호출했을 때의 **출력 품질** 이 과거 대비 악화되는 회귀는 탐지하지 못합니다.

Tier 3 runner 는 다음을 수행합니다.

1. `evals/evals.json` 의 각 eval prompt 를 실제로 Claude 에 주입하고 skill 을 활성화
2. skill 이 생성한 task directory 구조 + 내용을 capture
3. 별도 LLM (judge) 가 사전 정의된 rubric 에 따라 채점
4. 기준치 미달 시 CI fail

### 왜 지금 착수하지 않는가

현 시점에서 Tier 3 를 구축하면 다음 위험이 있습니다.

| 위험 | 설명 |
|---|---|
| Rubric overfitting | 현재 skill 이 생성하는 pattern 을 "정답" 으로 고정하게 되어, 실사용 중 발견되는 문제점 (ownership 이 너무 넓다, bundling 이 너무 크다 등) 을 오히려 정답 으로 강화 |
| Ground truth 부재 | 실제 회귀 를 정의하려면 "이 출력은 나쁘다" 라는 사용자 판단 data 가 필요. 현재 수집된 사례 0건 |
| 비용 불확실성 | judge LLM call + skill invocation 을 매 CI run 마다 돌리면 eval set 1회당 수만 token, 회귀 빈도 대비 가치 판단 불가 |
| Rubric 해상도 | `expected_output` 이 자연어 서술 상태라 judge 가 바로 채점하기 어려움. rubric 화가 선행되어야 함 |

### Readiness 체크리스트

Tier 3 착수 이전 **실사용 단계에서 수집** 해야 하는 data 입니다. 이 data 없이 Tier 3 를 시작하면 추측 기반 rubric 이 됩니다.

- [ ] Skill 사용 세션별 user 의 수정 요청 기록
  - 예: "이 task 를 쪼개줘", "bundling 이 너무 크다", "ownership 이 모호하다" 등
  - 각 요청이 **어떤 invariant 위반 신호** 인지 메모
- [ ] `human` vs `llm` mode 사용 빈도 및 체감 적정성
  - 너무 크다/작다 피드백이 mode 별로 어떻게 분포하는지
  - 제안한 size guideline (~10 files / ~300 LOC vs ~25 files / ~800 LOC) 이 현실적인지
- [ ] Output 이 spec 해석을 잘못한 사례
  - DB migration 을 feature task 에 섞은 사례 (Safety Invariant 위반)
  - Ownership 경계가 너무 넓어 병렬 실행 시 conflict 가 발생한 사례
  - Implementation Steps 가 너무 추상적이어서 agent 가 spec 재확인 없이는 진행 못한 사례
- [ ] Naming 전환 기간 발생한 실수
  - Legacy `001010` 과 new `000001-010` 혼재로 인한 confusion 사례
  - Dependency graph 에서 legacy 이름 참조 누락 사례
- [ ] Mode drift 사례
  - Step 5 에서 선택한 mode 가 Steps 6–9 에서 일관되게 반영되지 않은 사례

### 목표 착수 시점

**실사용 2–4 주 이후**, 위 체크리스트 data 가 충분히 수집된 시점. 정량 기준:

- 최소 10개 이상의 서로 다른 spec 에 대해 skill 실행 완료
- 최소 3건의 "이 output 은 틀렸다" 판정 및 그 이유 기록
- `human` / `llm` mode 각각 3회 이상 사용 경험

### Tier 3 구축 시 예상 작업 범위

1. **`evals.json` 을 rubric-ready 형태로 재작성**
   - 현재 `expected_output` 은 자연어 서술 — 이를 rubric item 리스트로 분해
   - 예: `- [ ] Phase 001 에 DB migration task 가 존재`, `- [ ] Ownership 이 path glob 수준` 등
2. **Judge prompt template 작성**
   - Judge 가 생성된 task directory 를 읽고 각 rubric 에 pass/fail + 근거를 출력하도록
3. **새 runner script 작성** — 예: `tools/scripts/run_task_generator_output_evals.py`
   - Skill 호출 interface 설계 (Anthropic API 직접 호출 vs Claude Code headless mode)
   - Judge call 분리
   - 결과 집계 + threshold 판정
4. **비용 / 실행 주기 결정**
   - 매 PR 실행은 부담 — 주 1회 nightly 또는 release 직전 trigger 가 현실적일 수 있음
   - Token budget 상한 설정
5. **Pre-commit 또는 CI 통합 (선택)**
   - 비용 구조 확정 후 결정

### 참고

- Rubric-based LLM judging 은 [Anthropic Evaluation Cookbook](https://github.com/anthropics/anthropic-cookbook/tree/main/misc/building_evals) 등에 pattern 이 정리되어 있음
- 유사한 LLM-as-judge 는 `ywc-spec-validate` skill 에서 rubric 형태의 quality dimension 을 사용하므로 참고 가능
