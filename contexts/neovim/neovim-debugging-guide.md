# Neovim/LazyVim 디버깅 가이드 (LLM 에이전트용)

Neovim/LazyVim 문제를 디버깅할 때 유용한 기법들.

## 1. Headless 모드 활용

Neovim을 headless로 실행하여 설정/모듈 상태를 빠르게 확인.

```bash
nvim --headless -c "lua <코드>" -c "qa" 2>&1
```

### 플러그인 설치 여부 확인

```bash
nvim --headless -c "lua print(pcall(require, 'telescope'))" -c "qa" 2>&1
# true = 설치됨, false = 미설치
```

### 설정값 확인

```bash
nvim --headless -c "lua print(vim.g.maplocalleader)" -c "qa" 2>&1
nvim --headless -c "lua print(vim.inspect(require('octo.config').values.mappings))" -c "qa" 2>&1
```

### 함수 존재 여부 확인

```bash
nvim --headless -c "lua local m = require('octo.utils'); print('edit_file:', m.edit_file)" -c "qa" 2>&1
# nil이면 함수 없음
```

## 2. 사용자에게 요청할 정보

### 에러 발생 시

- **전체 에러 메시지**: `E5108: Error executing lua...` 전체 복사
- **stack traceback**: 파일 경로와 줄 번호 포함

### 키 매핑 문제 시

```vim
:map <localleader>
:map <leader>
```
결과를 복사해달라고 요청. 매핑이 등록되어 있는지 확인 가능.

### which-key 문제 시

```vim
:lua require('which-key').show('\\')
```
수동 트리거로 동작하는지 확인 → 자동 트리거 설정 문제인지 판단.

### 특정 기능 비교 질문

"Leader(`<Space>`)는 which-key가 뜨나요?" 같은 비교 질문으로 문제 범위 좁히기.

## 3. Lua 에러 메시지 분석

```
E5108: Error executing lua: .../snacks/provider.lua:1098: attempt to index local 'opts' (a nil value)
```

| 부분 | 의미 |
|------|------|
| `E5108` | Neovim Lua 에러 코드 |
| `.../snacks/provider.lua:1098` | 파일 경로와 줄 번호 |
| `attempt to index local 'opts'` | `opts.something` 접근 시도 |
| `(a nil value)` | `opts`가 nil |

**해결 방향**: 해당 줄에서 `opts = opts or {}` 방어 코드 필요.

## 4. 플러그인 소스 코드 탐색

### 함수 정의 찾기

```bash
grep -n "function M.changed_files" ~/.local/share/nvim/lazy/octo.nvim/lua/**/*.lua
```

### 특정 변수/함수 사용처 찾기

```bash
grep -rn "utils.edit_file" ~/.local/share/nvim/lazy/octo.nvim/
```

### 다른 picker 구현 참고

동일 기능의 telescope/fzf-lua 버전과 snacks 버전 비교하여 누락된 코드 파악.

## 5. 문제 유형별 체크리스트

### "키가 안 먹혀요"

1. `:map <key>` 로 매핑 등록 확인
2. 등록됨 → which-key 트리거 문제 (수동 트리거 테스트)
3. 미등록 → 플러그인 설정/로드 문제

### "함수 호출 시 nil 에러"

1. 해당 함수가 실제로 존재하는지 확인 (headless 테스트)
2. 인자가 제대로 전달되는지 확인
3. 방어 코드(`opts = opts or {}`) 필요 여부

### "플러그인 업데이트 후 문제"

1. GitHub Issues/PR 검색
2. 최근 커밋에서 관련 변경 확인
3. 이전 버전으로 롤백 테스트 (lazy-lock.json)

## 6. 패치 적용 방식 선택

| 방식 | 장점 | 단점 |
|------|------|------|
| config에서 monkey-patch | 업데이트에 안전 | 복잡, 타이밍 이슈 |
| init에서 autocmd | 업데이트에 안전 | LazyLoad 타이밍 주의 |
| 플러그인 파일 직접 수정 | 확실함 | 업데이트 시 사라짐 |

**권장**: 간단한 문제는 config/init, 복잡한 버그는 직접 수정 + 문서화.

## 7. 유용한 디버깅 명령어

```vim
" 현재 버퍼 정보
:lua print(vim.bo.filetype)
:lua print(vim.api.nvim_buf_get_name(0))

" 로드된 플러그인 확인
:Lazy

" 메시지 확인
:messages

" 런타임 경로
:lua print(vim.inspect(vim.api.nvim_list_runtime_paths()))
```

## 8. LazyVim 특이사항

- **extras**: `lazyvim.json`에서 활성화된 extras 확인
- **plugin spec 충돌**: `config` 정의 시 LazyVim 기본 설정 덮어씀 주의
- **which-key**: leader는 자동 트리거, localleader는 수동 설정 필요할 수 있음
