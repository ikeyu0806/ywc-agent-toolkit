# ywc-agent-toolkit

> 이 문서는 현재 번역 중입니다. 전체 문서는 [English](README.md) 를 참조하세요.
>
> 번역에 기여하고 싶으신 분은 [Translation Issue](../../issues/new?template=translation.md) 를 작성해 주세요.

---

Claude Code 및 Codex 용 개발 워크플로우 자동화 스킬 모음입니다.
계획 수립, 사양서 작성, 태스크 분해, 코드 생성, 리뷰, 릴리스까지 전 과정을 지원합니다.

현재 Claude Code skill 26개와 Codex skill 27개를 제공합니다.

## 설치

### Claude Code 플러그인 마켓플레이스 (권장)

```bash
# 마켓플레이스 소스 추가 (최초 1회)
/plugin marketplace add yongwoon/ywc-agent-toolkit
```

명령 실행 후 Plugin UI의 **Marketplaces** 탭에서 **ywc-agent-toolkit**을 설치하세요.
클론이나 bash 없이 `~/.claude/skills/`에 자동 설치됩니다.

### bash 스크립트

```bash
git clone https://github.com/yongwoon/ywc-agent-toolkit.git
cd ywc-agent-toolkit

# Claude Code
bash scripts/install.sh --cc

# Codex
bash scripts/install.sh --codex

# 양쪽 모두
bash scripts/install.sh --all
```

자세한 내용은 [README.md](README.md) 를 참조하세요.
