# add-chapter/add-section 커맨드 제거 계획

## 1. 개요

이 계획은 dokhak 플러그인에서 `add-chapter`와 `add-section` 커맨드를 완전히 제거하기 위한 단계별 작업을 정의합니다.

**제거 이유**: 현재 구현 내용이 부족하여 일단 깔끔하게 제거하고 이후에 별도로 추가 예정

---

## 2. 작업 범위 요약

| 작업 유형 | 파일 수 | 파일 목록 |
|----------|---------|-----------|
| **삭제** | 2 | `commands/add-chapter.md`, `commands/add-section.md` |
| **수정** | 2 | `README.md`, `README.ko.md` |
| **수정 불필요** | 다수 | CLAUDE.md, agents/*, skills/*, 기타 commands/* |

---

## 3. 삭제할 파일 상세

### 3.1 `commands/add-chapter.md`
- **크기**: 170줄
- **내용**: 새 챕터를 plan.md와 task.md에 추가하는 커맨드 정의

### 3.2 `commands/add-section.md`
- **크기**: 215줄
- **내용**: 기존 챕터에 새 섹션을 추가하는 커맨드 정의

---

## 4. README.md 수정 상세 (영문)

파일 경로: `README.md`

### 4.1 Commands 테이블 (라인 144-145)
**삭제할 내용**:
```markdown
| `/add-chapter`      | Add a new chapter to plan.md and task.md                           |
| `/add-section`      | Add a new section to an existing chapter                           |
```

### 4.2 Command Details 섹션 (라인 178-196)
**삭제할 내용**: `/add-chapter` 및 `/add-section` 상세 사용법 섹션 전체 (약 19줄)

### 4.3 Plugin Structure 다이어그램 (라인 323-324)
**삭제할 내용**:
```markdown
│   ├── add-chapter.md        # Add chapter
│   ├── add-section.md        # Add section
```

### 4.4 FAQ 섹션 (라인 375-376)
**삭제할 내용**:
```markdown
- Add chapter: `/dokhak:add-chapter "Chapter Name" --part 1 --pages 20`
- Add section: `/dokhak:add-section "Section Name" --chapter 3 --pages 5`
```
**수정 후**:
```markdown
### Q: I want to modify the curriculum structure

For major changes, edit `plan.md` and `task.md` directly, then run `/dokhak:doctor` to check consistency
```

---

## 5. README.ko.md 수정 상세 (한국어)

파일 경로: `README.ko.md`

### 5.1 구조 수정 커맨드 테이블 (라인 186-190)
**삭제할 내용**: add-chapter, add-section 행 (2줄)
**추가 작업**: 테이블이 doctor만 남으므로 섹션 제목을 "유지보수 커맨드"로 변경 고려

### 5.2 상세 사용법 섹션 (라인 223-241)
**삭제할 내용**: `/dokhak:add-chapter` 및 `/dokhak:add-section` 상세 사용법 (약 19줄)

### 5.3 플러그인 디렉토리 구조 (라인 391-392)
**삭제할 내용**:
```markdown
│   ├── add-chapter.md
│   ├── add-section.md
```

### 5.4 FAQ 섹션 (라인 471-472)
**삭제할 내용**:
```markdown
- 챕터 추가: `/dokhak:add-chapter "챕터명" --part 1 --pages 20`
- 섹션 추가: `/dokhak:add-section "섹션명" --chapter 3 --pages 5`
```
**수정 후**:
```markdown
### Q: 커리큘럼 구조를 수정하고 싶어요

대규모 수정이 필요하면 `plan.md`와 `task.md`를 직접 편집한 후 `/dokhak:doctor`로 일관성을 확인하세요
```

---

## 6. 실행 순서

### Phase 1: 파일 삭제
- [ ] 1.1 commands/add-chapter.md 파일 삭제
- [ ] 1.2 commands/add-section.md 파일 삭제

### Phase 2: README.md 수정
- [ ] 2.1 Commands 테이블에서 add-chapter/add-section 행 삭제
- [ ] 2.2 Command Details에서 add-chapter/add-section 섹션 삭제
- [ ] 2.3 Plugin Structure에서 파일 참조 삭제
- [ ] 2.4 FAQ 섹션 수정

### Phase 3: README.ko.md 수정
- [ ] 3.1 구조 수정 커맨드 테이블에서 행 삭제 및 섹션 제목 수정
- [ ] 3.2 상세 사용법에서 add-chapter/add-section 섹션 삭제
- [ ] 3.3 플러그인 디렉토리 구조에서 파일 참조 삭제
- [ ] 3.4 FAQ 섹션 수정

### Phase 4: 검증
- [ ] 4.1 commands/ 디렉터리에 add-chapter.md, add-section.md가 없음 확인
- [ ] 4.2 README.md에서 "add-chapter", "add-section" 문자열 검색 - 결과 없어야 함
- [ ] 4.3 README.ko.md에서 "add-chapter", "add-section" 문자열 검색 - 결과 없어야 함
- [ ] 4.4 git status로 변경사항 확인

---

## 7. 검증 명령어

```bash
# 커맨드 파일 삭제 확인
ls commands/

# README에서 삭제된 커맨드 참조 검색 (결과 없어야 함)
grep -n "add-chapter\|add-section" README.md
grep -n "add-chapter\|add-section" README.ko.md

# 전체 프로젝트에서 삭제된 커맨드 참조 검색
grep -r "add-chapter\|add-section" . --include="*.md"
```

---

## 8. 롤백 계획

문제 발생 시:
```bash
git checkout -- commands/add-chapter.md commands/add-section.md README.md README.ko.md
```

---

## 9. 영향받는 파일 목록

### 삭제 대상
- `commands/add-chapter.md`
- `commands/add-section.md`

### 수정 대상
- `README.md` - 4개 위치 수정
- `README.ko.md` - 4개 위치 수정

### 영향 없음 (확인 완료)
- `CLAUDE.md`
- `agents/*.md` - 모든 에이전트 파일
- `skills/**/*.md` - 모든 스킬 파일
- `commands/init.md`
- `commands/write.md`
- `commands/continue.md`
- `commands/status.md`
- `commands/doctor.md`
