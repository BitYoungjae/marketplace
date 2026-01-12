#!/bin/bash
#
# cc-docs-sync.sh - Claude Code 공식 문서 동기화 스크립트
#
# 사용법:
#   ./scripts/cc-docs-sync.sh [옵션]
#
# 옵션:
#   --dry-run                    실제 다운로드 없이 변경될 파일 목록만 표시
#   --verbose                    상세 로그 출력
#   --include-prompt-engineering prompt-engineering 문서도 동기화
#   --help                       도움말 표시

set -euo pipefail

# 스크립트 위치 기준으로 프로젝트 루트 찾기
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 설정
CC_BASE_URL="https://code.claude.com/docs/en"
CC_TARGET_DIR="${PROJECT_ROOT}/contexts/cc"

# Claude Code 문서 목록
CC_DOCS=(
    "hooks.md"
    "hooks-guide.md"
    "plugins.md"
    "plugins-reference.md"
    "skills.md"
    "slash-commands.md"
    "sub-agents.md"
)

# 커스텀 파일 (동기화 제외)
CUSTOM_FILES=(
    "ask-user-question-tool.md"
    "task-tool-context.md"
)

# Prompt Engineering 설정
PE_BASE_URL="https://platform.claude.com/docs/en/build-with-claude/prompt-engineering"
PE_TARGET_DIR="${PROJECT_ROOT}/contexts/cc/prompt-engineering"
PE_DOCS=(
    "be-clear-and-direct.md"
    "chain-of-thought.md"
    "chain-prompts.md"
    "extended-thinking-tips.md"
    "long-context-tips.md"
    "multishot-prompting.md"
    "prefill-claudes-response.md"
    "system-prompts.md"
    "use-xml-tags.md"
)

# 옵션 플래그
DRY_RUN=false
VERBOSE=false
INCLUDE_PE=false

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 함수: 로그 출력
log() {
    echo -e "$1"
}

log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${BLUE}[VERBOSE]${NC} $1"
    fi
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

log_skip() {
    echo -e "${YELLOW}○${NC} $1"
}

# 함수: 도움말 표시
show_help() {
    cat << EOF
cc-docs-sync.sh - Claude Code 공식 문서 동기화 스크립트

사용법:
    ./scripts/cc-docs-sync.sh [옵션]

옵션:
    --dry-run                    실제 다운로드 없이 변경될 파일 목록만 표시
    --verbose                    상세 로그 출력
    --include-prompt-engineering prompt-engineering 문서도 동기화
    --help                       도움말 표시

예시:
    ./scripts/cc-docs-sync.sh
    ./scripts/cc-docs-sync.sh --dry-run
    ./scripts/cc-docs-sync.sh --verbose --include-prompt-engineering

동기화 대상:
    - Claude Code 문서: code.claude.com/docs/en/
    - Prompt Engineering: platform.claude.com (--include-prompt-engineering 옵션 필요)

커스텀 파일 (동기화 제외):
    - ask-user-question-tool.md
    - task-tool-context.md
EOF
}

# 함수: 파일 다운로드
download_file() {
    local url="$1"
    local output="$2"
    local name="$3"

    log_verbose "다운로드: $url -> $output"

    if [ "$DRY_RUN" = true ]; then
        log_skip "$name (dry-run)"
        return 0
    fi

    local http_code
    http_code=$(curl -sL -w "%{http_code}" "$url" -o "$output")

    if [ "$http_code" = "200" ]; then
        log_success "$name"
        return 0
    else
        log_error "$name (HTTP $http_code)"
        rm -f "$output" 2>/dev/null
        return 1
    fi
}

# 함수: Claude Code 문서 동기화
sync_cc_docs() {
    log "\n${BLUE}## Claude Code 문서 (code.claude.com)${NC}\n"

    # 대상 디렉토리 확인
    if [ ! -d "$CC_TARGET_DIR" ]; then
        log_verbose "디렉토리 생성: $CC_TARGET_DIR"
        if [ "$DRY_RUN" = false ]; then
            mkdir -p "$CC_TARGET_DIR"
        fi
    fi

    local success=0
    local failed=0

    for doc in "${CC_DOCS[@]}"; do
        if download_file "${CC_BASE_URL}/${doc}" "${CC_TARGET_DIR}/${doc}" "$doc"; then
            success=$((success + 1))
        else
            failed=$((failed + 1))
        fi
    done

    log_verbose "성공: $success, 실패: $failed"
}

# 함수: Prompt Engineering 문서 동기화
sync_pe_docs() {
    log "\n${BLUE}## Prompt Engineering 문서 (platform.claude.com)${NC}\n"

    # 대상 디렉토리 확인
    if [ ! -d "$PE_TARGET_DIR" ]; then
        log_verbose "디렉토리 생성: $PE_TARGET_DIR"
        if [ "$DRY_RUN" = false ]; then
            mkdir -p "$PE_TARGET_DIR"
        fi
    fi

    local success=0
    local failed=0

    for doc in "${PE_DOCS[@]}"; do
        local output_file="${PE_TARGET_DIR}/${doc}"
        if download_file "${PE_BASE_URL}/${doc}" "$output_file" "$doc"; then
            success=$((success + 1))
        else
            failed=$((failed + 1))
        fi
    done

    log_verbose "성공: $success, 실패: $failed"
}

# 함수: 커스텀 파일 목록 표시
show_custom_files() {
    log "\n${BLUE}## 건너뛴 파일 (커스텀)${NC}\n"
    for file in "${CUSTOM_FILES[@]}"; do
        log_skip "$file"
    done
}

# 인자 파싱
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --include-prompt-engineering)
            INCLUDE_PE=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo "알 수 없는 옵션: $1"
            echo "도움말: $0 --help"
            exit 1
            ;;
    esac
done

# 메인 실행
log "${BLUE}# CC Docs Sync${NC}"

if [ "$DRY_RUN" = true ]; then
    log "${YELLOW}(dry-run 모드)${NC}"
fi

log_verbose "프로젝트 루트: $PROJECT_ROOT"
log_verbose "CC 대상 디렉토리: $CC_TARGET_DIR"

# Claude Code 문서 동기화
sync_cc_docs

# Prompt Engineering 문서 동기화 (옵션)
if [ "$INCLUDE_PE" = true ]; then
    sync_pe_docs
else
    log "\n${YELLOW}## prompt-engineering/ (별도 소스)${NC}"
    log "이 디렉토리는 --include-prompt-engineering 옵션으로 동기화할 수 있습니다.\n"
fi

# 커스텀 파일 목록
show_custom_files

log "\n${GREEN}동기화 완료!${NC}"
