# paper_sjkim — Zotero 논문 라이브러리 동기화 시스템

Zotero 라이브러리(서지 데이터)는 Zotero 계정 동기화가, PDF 본문은 Syncthing이,
노트/BibTeX/스크립트는 이 Git 저장소가 맡는 3분할 구조.

## 전체 구조

```
Desktop\Zotero\        Zotero 데이터 폴더 (zotero.sqlite 등). 건드릴 일 거의 없음.
Desktop\Papers\        실제 PDF 파일. Syncthing으로 두 컴퓨터 간 동기화. Git 무관.
Desktop\paper_sjkim\   이 저장소. notes/ bib/ scripts/만 존재, PDF 없음. GitHub로 push/pull.
```

| 구성요소 | 동기화 수단 | 비용 |
|---|---|---|
| 서지 메타데이터, 컬렉션 구조, 태그, Zotero 노트 | Zotero 계정 동기화 (이미 켜져 있음, 계정: `sojinkim_0512`) | 무료 |
| PDF 본문 (`Desktop\Papers`) | Syncthing (P2P, 클라우드 용량 제한 없음) | 무료 |
| `bib/references.bib`, `notes/*.md`, 스크립트 | 이 Git 저장소 → GitHub (`paper_sjkim`) | 무료 |

WebDAV(Koofr)는 더 이상 필요 없음 — Zotero 설정에서 File Syncing을 끈다.

## 왜 PDF를 Git으로 안 올리나

291개, 1.2GB인데 계속 늘어난다. GitHub 무료 LFS는 1GB/월로 금방 한도를 넘고,
어차피 PDF는 한 번 저장하면 거의 안 바뀌는 파일이라 버전 관리 이점이 적다.
Syncthing이 이 용도에 더 적합하다 (용량 제한 없음, P2P라 클라우드 서버 안 거침).

## 최초 설정 (Windows, 완료됨)

1. `Desktop\Zotero_backup_YYYYMMDD\`에 마이그레이션 전 원본 백업 보관 중.
2. `Desktop\Papers\` 생성.
3. Zotero → Settings → Advanced → Files and Folders →
   "Linked Attachment Base Directory"를 `Desktop\Papers`로 지정.
4. Zotero → Settings → Sync → File Syncing → WebDAV 체크 해제 (계정 동기화는 유지).
5. Attanger 설정 (Zotero Settings → Attanger)에서 이름 규칙을
   `{%a} - {%y} - {%t}` 정도로 지정한 뒤, 라이브러리 전체 선택 →
   우클릭 → Attanger → 첨부파일을 Base Directory로 이동 + Linked Attachment로 전환 실행.
   실행 후 몇 개 항목을 열어 PDF가 정상적으로 열리는지 확인.
6. Better BibTeX → 라이브러리 우클릭 → Export → 형식 Better BibTeX,
   "Keep updated" 체크, 저장 위치 `Desktop\paper_sjkim\bib\references.bib`.
7. Syncthing 설치 후 `Desktop\Papers`를 공유 폴더로 등록.

## 우분투 컴퓨터 설정 (처음 한 번)

```bash
sudo apt update && sudo apt install zotero syncthing git git-lfs -y   # zotero는 배포판에 따라 tarball 설치 필요할 수 있음
git clone https://github.com/sosejin-ust/paper_sjkim.git ~/paper_sjkim
mkdir -p ~/Papers
```

1. Zotero 설치 후 같은 계정(`sojinkim_0512`)으로 로그인 → 서지 데이터 자동 동기화됨.
2. Zotero → Settings → Advanced → Linked Attachment Base Directory를 `~/Papers`로 지정
   (Windows와 절대경로는 달라도 됨 — Zotero는 상대경로만 DB에 저장하므로 문제없음).
3. Better BibTeX, Attanger 플러그인 설치 (다시 변환 작업을 할 필요는 없음, Windows에서 이미 전환됨).
4. Syncthing 실행 → Windows 컴퓨터와 Device ID 교환 → `Desktop\Papers` ↔ `~/Papers` 폴더 페어링.
5. Syncthing이 첫 동기화(1.2GB)를 끝낼 때까지 대기.

## 평소 사용법

작업 시작 전 / 끝난 후 한 번씩:

- Windows: `Desktop\paper_sjkim` 에서 `.\scripts\sync.ps1` 실행
- Ubuntu: `~/paper_sjkim` 에서 `./scripts/sync.sh` 실행

Zotero 서지 데이터와 Syncthing PDF는 각자 알아서 실시간/주기적으로 동기화되므로
따로 신경 쓸 필요 없음. `sync.ps1`/`sync.sh`는 `bib/references.bib`와 `notes/`만 다룬다.

## 새 논문 추가 워크플로

1. Zotero에 평소처럼 PDF 추가 (드래그 앤 드롭 등).
2. Attanger가 자동으로 `Desktop\Papers`(또는 `~/Papers`)로 이동 + Linked Attachment 전환
   (Attanger 설정에서 "새 첨부파일 자동 처리"를 켜두면 매번 수동으로 안 해도 됨).
3. Better BibTeX가 `references.bib`를 자동 갱신.
4. Syncthing이 PDF를, `sync.ps1`/`sync.sh`가 bib/notes를 다음 실행 때 동기화.

## 문제 생겼을 때

- PDF가 안 열리면: Zotero의 Base Directory 설정이 맞는지, Syncthing이 해당 파일을
  다 받았는지 확인.
- 라이브러리가 꼬였으면: `Desktop\Zotero_backup_YYYYMMDD\`의 `zotero.sqlite`와
  `storage\`로 복구 가능 (Zotero 종료 후 덮어쓰기).
