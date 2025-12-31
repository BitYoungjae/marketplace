# nvim-doctor

**AI 기반 분석으로 Neovim 설정 문제를 진단하고 해결합니다.**

`brew doctor`처럼 Neovim 환경을 진단합니다. 플러그인 충돌, 키바인딩 문제, 성능 병목, LSP 이슈, 설정 오류를 해결할 수 있도록 도와줍니다.

[English Documentation](./README.md)

## 주요 기능

- **오류 진단**: Lua 에러 메시지, 스택 트레이스 분석 및 근본 원인 파악
- **설정 감사**: 구조, 성능, 보안, 호환성 기준으로 A-F 등급 부여
- **플러그인 조사**: GitHub를 통해 플러그인 버전 호환성 및 브레이킹 체인지 조사
- **키맵 디버깅**: leader/localleader 이슈, 모드 충돌, which-key 문제 진단
- **LSP 트러블슈팅**: 서버 연결, 기능 확인, 언어별 설정 디버깅
- **성능 분석**: 시작 시간 프로파일링, 병목 현상 파악, 지연 로딩 최적화
- **보안 검사**: 노출된 인증정보, 안전하지 않은 명령어, modeline/exrc 위험 감지
- **Deprecated API 감지**: Neovim 0.9-0.12 API 변경사항 및 마이그레이션 추적

## 설치

```bash
# 마켓플레이스 추가
/plugin marketplace add bityoungjae/marketplace

# 플러그인 설치
/plugin install nvim-doctor@bityoungjae-marketplace
```

## 사용법

### `/nvim-doctor:diagnose <에러-메시지-또는-증상>`

Neovim 문제 진단을 위한 메인 명령어입니다.

```
/nvim-doctor:diagnose "E5108: Error executing lua: attempt to index nil value"
```

```
/nvim-doctor:diagnose "업데이트 후 키맵이 작동하지 않음"
```

```
/nvim-doctor:diagnose "시작 시간이 느림"
```

```
/nvim-doctor:diagnose "Python 파일에 LSP가 연결되지 않음"
```

명령어가 자동으로 수행하는 작업:
1. 시스템 정보 수집 (Neovim 버전, 설정 경로, 플러그인 수, 시작 시간)
2. 문제 유형 분류
3. 적절한 전문 에이전트로 라우팅

## 아키텍처

nvim-doctor는 각 에이전트가 특정 유형의 진단을 전문으로 하는 멀티 에이전트 아키텍처를 사용합니다:

```
사용자 문제
    │
    ▼
┌───────────────────────────┐
│  /nvim-doctor:diagnose    │  ← 진입점
│      (메인 명령어)        │
└───────────────────────────┘
    │
    ├─── 복잡한 진단 ────→ nvim-diagnostician (sonnet)
    │                      사용: neovim-debugging 스킬
    │
    ├─── 설정 검토 ──────→ config-auditor (haiku)
    │                      사용: config-auditing 스킬
    │
    └─── 플러그인 이슈 ──→ plugin-investigator (haiku)
                           사용: GitHub 검색을 위한 WebSearch
```

### 에이전트

| 에이전트 | 모델 | 목적 |
|----------|------|------|
| `nvim-diagnostician` | Sonnet | 가설 검증을 통한 심층 근본 원인 분석 |
| `config-auditor` | Haiku | 빠른 설정 스캔 및 A-F 등급 부여 |
| `plugin-investigator` | Haiku | 플러그인 버전 호환성 및 GitHub 조사 |

### 스킬 (지식 베이스)

**neovim-debugging**
- 일반적인 문제에 대한 진단 플로우차트
- 솔루션이 포함된 에러 패턴 데이터베이스
- 플러그인별 디버깅 가이드 (lazy.nvim, which-key, LSP, Treesitter, Telescope, nvim-cmp, Snacks.nvim, LazyVim)

**config-auditing**
- 5개 카테고리 감사 체크리스트 (구조, 성능, 보안, 호환성, 중복)
- lazy.nvim, vim.opt, 키맵 모범 사례
- Neovim 0.9-0.12 Deprecated API 레퍼런스

## 감사 등급 시스템

설정을 감사할 때 nvim-doctor는 다음 등급을 부여합니다:

| 등급 | 기준 | 의미 |
|------|------|------|
| **A** | 크리티컬 0개, 경고 0-2개 | 우수 - 프로덕션 준비 완료 |
| **B** | 크리티컬 0개, 경고 3-5개 | 양호 - 약간의 개선 가능 |
| **C** | 크리티컬 0개, 경고 6개+ 또는 크리티컬 1개 | 보통 - 문제 해결 필요 |
| **D** | 크리티컬 2-3개 | 미흡 - 주의 필요 |
| **F** | 크리티컬 4개 이상 | 불합격 - 즉시 수정 필요 |

## 진단 출력 형식

nvim-doctor는 구조화된 증거 기반 진단을 제공합니다:

```xml
<diagnosis>
  근본 원인: [증거와 함께 확인된 원인]
  증거: [확인에 사용된 명령어/파일]
  해결책: [수정을 위한 구체적인 단계]
  예방: [향후 방지 방법]
</diagnosis>
```

## 지원하는 Neovim 배포판

- 바닐라 Neovim 설정
- LazyVim
- NvChad
- AstroNvim
- LunarVim
- 커스텀 설정

## 요구사항

- Claude Code CLI
- Neovim 0.9+ (전체 호환성 검사를 위해)
- Neovim 설정 디렉토리 접근 권한

## 라이선스

MIT

## 저자

**BitYoungjae** - [bityoungjae@gmail.com](mailto:bityoungjae@gmail.com)
