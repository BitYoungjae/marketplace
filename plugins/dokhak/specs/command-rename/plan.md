# Implementation Plan: Command Renaming

## Summary

이 계획은 dokhak 플러그인의 세 가지 커맨드 이름 변경을 다룹니다:

| Before | After |
|--------|-------|
| `init-project` | `init` |
| `write-doc` | `write` |
| `continue-session` | `continue` |

**총 변경 규모**: 3개 파일 이름 변경 + 15개 파일 내용 수정 (106+ 위치)

---

## Phase 1: 파일 내용 수정 (파일 이름 변경 전)

> **Rationale**: 파일 이름을 변경하기 전에 내용을 먼저 수정합니다. 이렇게 하면 git이 히스토리를 올바르게 추적할 수 있습니다.

### 1.1 커맨드 파일 내부 참조 수정

**`plugins/dokhak/commands/init-project.md`** (이름 변경 대상)
| Line | Before | After |
|------|--------|-------|
| 149 | `/write-doc` | `/write` |
| 181 | `/write-doc` | `/write` |

**`plugins/dokhak/commands/add-chapter.md`**
| Line | Before | After |
|------|--------|-------|
| 15 | `run /init-project first` | `run /init first` |
| 18 | `run /init-project first` | `run /init first` |
| 48 | `Run /init-project first` | `Run /init first` |
| 144 | `/write-doc` | `/write` |
| 161 | `/init-project first` | `/init first` |

**`plugins/dokhak/commands/add-section.md`**
| Line | Before | After |
|------|--------|-------|
| 15 | `run /init-project first` | `run /init first` |
| 48 | `Run /init-project first` | `Run /init first` |
| 143 | `/write-doc` | `/write` |
| 170 | `/init-project first` | `/init first` |

**`plugins/dokhak/commands/status.md`**
| Line | Before | After |
|------|--------|-------|
| 24 | `Run /init-project first` | `Run /init first` |
| 30 | `Run /init-project first` | `Run /init first` |

**`plugins/dokhak/commands/doctor.md`**
| Line | Before | After |
|------|--------|-------|
| 54 | `running '/init-project'` | `running '/init'` |
| 66 | `Run /init-project (Recommended)` | `Run /init (Recommended)` |
| 84 | `Run /init-project` | `Run /init` |

### 1.2 에이전트 파일 수정

**`plugins/dokhak/agents/project-interviewer.md`**
| Line | Before | After |
|------|--------|-------|
| 3 | `/init-project is invoked` | `/init is invoked` |

### 1.3 스킬 파일 수정

**`plugins/dokhak/skills/domain-profiles/SKILL.md`**
| Line | Before | After |
|------|--------|-------|
| 13 | `/init-project` | `/init` |

**`plugins/dokhak/skills/project-interview/SKILL.md`**
| Line | Before | After |
|------|--------|-------|
| 3 | `during /init-project` | `during /init` |

**`plugins/dokhak/skills/project-scaffolder/SKILL.md`**
| Line | Before | After |
|------|--------|-------|
| 3 | `/init-project command is invoked` | `/init command is invoked` |

**`plugins/dokhak/skills/project-scaffolder/persona-template.md`**
| Line | Before | After |
|------|--------|-------|
| 252 | `/init-project` | `/init` |

**`plugins/dokhak/skills/project-scaffolder/claude-md-template.md`**
| Line | Before | After |
|------|--------|-------|
| 26 | `/write-doc` | `/write` |

### 1.4 CLAUDE.md 파일 수정

**`CLAUDE.md` (루트)**
| Line | Before | After |
|------|--------|-------|
| 16 | `/init-project, /write-doc, etc.` | `/init, /write, etc.` |
| 31 | `(/init-project)` | `(/init)` |
| 40 | `(/write-doc, /continue-session)` | `(/write, /continue)` |

**`plugins/dokhak/CLAUDE.md`**
| Line | Before | After |
|------|--------|-------|
| 31 | `/init-project` | `/init` |
| 40 | `/write-doc, /continue-session` | `/write, /continue` |

### 1.5 README 파일 수정

**`README.md`** (24 locations)

| Line | Change |
|------|--------|
| 32 | `/dokhak:init-project` → `/dokhak:init` |
| 66 | `/dokhak:write-doc` → `/dokhak:write` |
| 69 | `/dokhak:write-doc 2-3` → `/dokhak:write 2-3` |
| 72 | `/dokhak:continue-session 5` → `/dokhak:continue 5` |
| 141 | `/init-project` → `/init` |
| 142 | `/write-doc` → `/write` |
| 143 | `/continue-session` → `/continue` |
| 151 | `/init-project` → `/init` |
| 154 | `/dokhak:init-project [--resume]` → `/dokhak:init [--resume]` |
| 159 | `/write-doc` → `/write` |
| 162 | `/dokhak:write-doc [section-id]` → `/dokhak:write [section-id]` |
| 168 | `/continue-session` → `/continue` |
| 171 | `/dokhak:continue-session [count]` → `/dokhak:continue [count]` |
| 227 | `/continue-session` → `/continue` |
| 235 | `/dokhak:init-project` → `/dokhak:init` |
| 245 | `/dokhak:write-doc or /dokhak:continue-session 3` → `/dokhak:write or /dokhak:continue 3` |
| 292 | `(init-project)` → `(init)` |
| 293 | `(init-project)` → `(init)` |
| 297 | `/init-project` → `/init` |
| 320 | `init-project.md` → `init.md` |
| 321 | `write-doc.md` → `write.md` |
| 322 | `continue-session.md` → `continue.md` |
| 344 | `/dokhak:continue-session 5` → `/dokhak:continue 5` |
| 367 | `/dokhak:init-project --resume` → `/dokhak:init --resume` |

**`README.ko.md`** (26 locations)

| Line | Change |
|------|--------|
| 51 | `init-project` → `init` |
| 54 | `/dokhak:init-project` → `/dokhak:init` |
| 90 | `/dokhak:write-doc` → `/dokhak:write` |
| 93 | `/dokhak:write-doc 2-3` → `/dokhak:write 2-3` |
| 96 | `/dokhak:continue-session 5` → `/dokhak:continue 5` |
| 179 | `/dokhak:init-project` → `/dokhak:init` |
| 180 | `/dokhak:write-doc` → `/dokhak:write` |
| 181 | `/dokhak:continue-session` → `/dokhak:continue` |
| 194 | `/dokhak:init-project` → `/dokhak:init` |
| 197 | `/dokhak:init-project [--resume]` → `/dokhak:init [--resume]` |
| 202 | `/dokhak:write-doc` → `/dokhak:write` |
| 205 | `/dokhak:write-doc [섹션ID]` → `/dokhak:write [섹션ID]` |
| 210 | `/dokhak:write-doc 2-3` → `/dokhak:write 2-3` |
| 212 | `/dokhak:continue-session` → `/dokhak:continue` |
| 215 | `/dokhak:continue-session [개수]` → `/dokhak:continue [개수]` |
| 221 | `/dokhak:continue-session 5` → `/dokhak:continue 5` |
| 274 | `/continue-session` → `/continue` |
| 284 | `/dokhak:init-project` → `/dokhak:init` |
| 294 | `/dokhak:write-doc or /dokhak:continue-session 3` → `/dokhak:write or /dokhak:continue 3` |
| 388 | `init-project.md` → `init.md` |
| 389 | `write-doc.md` → `write.md` |
| 390 | `continue-session.md` → `continue.md` |
| 412 | `/dokhak:init-project` → `/dokhak:init` |
| 434 | `/dokhak:continue-session 5` → `/dokhak:continue 5` |
| 459 | `/dokhak:init-project --resume` → `/dokhak:init --resume` |
| 467 | `/dokhak:write-doc` → `/dokhak:write` |

---

## Phase 2: 파일 이름 변경

모든 내용 수정이 완료된 후 커맨드 파일 이름을 변경합니다:

```bash
cd /home/bityoungjae/Work/bityoungjae-marketplace/plugins/dokhak/commands

git mv init-project.md init.md
git mv write-doc.md write.md
git mv continue-session.md continue.md
```

> `git mv`를 사용하면 git이 파일 이름 변경을 추적하여 히스토리가 보존됩니다.

---

## Phase 3: 검증

### 3.1 이전 이름 참조가 남아있지 않은지 확인

```bash
grep -rn "init-project\|write-doc\|continue-session" \
  plugins/dokhak --include="*.md"

grep -n "init-project\|write-doc\|continue-session" CLAUDE.md
```

**Expected**: 결과 없음 (빈 출력)

### 3.2 새 이름 참조가 존재하는지 확인

```bash
grep -rn "dokhak:init\|dokhak:write\|dokhak:continue" \
  plugins/dokhak --include="*.md" | head -10
```

**Expected**: 여러 결과가 새 커맨드 이름으로 표시됨

### 3.3 파일 구조 확인

```bash
ls -la plugins/dokhak/commands/
```

**Expected files**:
- `init.md` (renamed from init-project.md)
- `write.md` (renamed from write-doc.md)
- `continue.md` (renamed from continue-session.md)
- `add-chapter.md` (unchanged)
- `add-section.md` (unchanged)
- `status.md` (unchanged)
- `doctor.md` (unchanged)

---

## Phase 4: Git 커밋

```bash
git add -A
git status  # 모든 변경 사항 확인

git commit -m "refactor(dokhak): rename commands for brevity

- init-project -> init
- write-doc -> write
- continue-session -> continue

Updates all references across:
- Command files (3 renamed, 4 edited)
- Agent and skill files (5 files)
- Documentation (README.md, README.ko.md)
- CLAUDE.md files (2 files)

BREAKING CHANGE: Old command names no longer work.
Users must update any scripts or workflows using:
- /dokhak:init-project -> /dokhak:init
- /dokhak:write-doc -> /dokhak:write
- /dokhak:continue-session -> /dokhak:continue"
```

---

## Rollback Strategy

문제 발생 시 롤백 방법:

### Option A: Git Revert (권장)

```bash
git revert HEAD
```

### Option B: Manual Rollback

1. 파일 이름 복원:
   ```bash
   cd plugins/dokhak/commands
   git mv init.md init-project.md
   git mv write.md write-doc.md
   git mv continue.md continue-session.md
   ```

2. 내용 복원 (역방향 치환):
   - `/init` → `/init-project`
   - `/write` → `/write-doc`
   - `/continue` → `/continue-session`

---

## Potential Challenges

### 1. False Positives
`/init`, `/write`, `/continue`는 짧은 패턴이므로 의도치 않은 문자열과 매칭될 수 있음.
- **Mitigation**: `/dokhak:init` 같은 전체 패턴 사용
- 각 치환을 컨텍스트에서 검토

### 2. External References
사용자의 스크립트나 노트에서 이전 커맨드 이름을 참조하고 있을 수 있음.
- 릴리스 노트에 변경 사항 문서화 권장

---

## Implementation Order Summary

1. **Phase 1.1-1.3**: 커맨드/에이전트/스킬 파일 내부 수정
2. **Phase 1.4**: CLAUDE.md 파일 수정
3. **Phase 1.5**: README 파일 수정
4. **Phase 2**: `git mv`로 커맨드 파일 이름 변경
5. **Phase 3**: 검증 체크 실행
6. **Phase 4**: 변경 사항 커밋
