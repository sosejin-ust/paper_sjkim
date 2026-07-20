# paper_sjkim — Zotero 논문 라이브러리 동기화 시스템

Zotero 라이브러리(서지 데이터)는 Zotero 계정 동기화가, PDF 본문은 Syncthing이,
노트/BibTeX/스크립트는 이 Git 저장소가 맡는 3분할 구조.

Zotero의 첨부파일 관리 방식(managed storage)은 그대로 유지한다 — Linked Attachment로
전환하는 과정이 번거로워서, 그냥 Zotero가 쓰는 `storage` 폴더 자체를 Syncthing으로
통째로 복제하는 훨씬 단순한 방식을 쓴다.

## 전체 구조

```
Desktop\Zotero\           Zotero 데이터 폴더 (zotero.sqlite, storage\ 등).
Desktop\Zotero\storage\   실제 PDF가 들어있는 폴더. Syncthing으로 두 컴퓨터 간 통째로 동기화.
Desktop\paper_sjkim\      이 저장소. notes/ bib/ scripts/만 존재, PDF 없음. GitHub로 push/pull.
```

| 구성요소 | 동기화 수단 | 비용 |
|---|---|---|
| 서지 메타데이터, 컬렉션 구조, 태그, Zotero 노트 | Zotero 계정 동기화 (이미 켜져 있음, 계정: `sojinkim_0512`) | 무료 |
| PDF 본문 (`Desktop\Zotero\storage`) | Syncthing (P2P, 클라우드 용량 제한 없음) | 무료 |
| `bib/references.bib`, `notes/*.md`, 스크립트 | 이 Git 저장소 → GitHub (`paper_sjkim`) | 무료 |

WebDAV(Koofr)는 더 이상 필요 없음 — Zotero 설정에서 File Syncing을 끈다
(Syncthing과 동시에 같은 폴더를 건드리면 충돌 위험이 있어서 하나만 쓴다).

## 왜 PDF를 Git으로 안 올리나

291개, 1.2GB인데 계속 늘어난다. GitHub 무료 LFS는 1GB/월로 금방 한도를 넘고,
어차피 PDF는 한 번 저장하면 거의 안 바뀌는 파일이라 버전 관리 이점이 적다.
Syncthing이 이 용도에 더 적합하다 (용량 제한 없음, P2P라 클라우드 서버 안 거침).

## 왜 Attanger/Linked Attachment로 안 바꿨나

처음엔 첨부파일을 전부 Linked Attachment로 전환해서 별도 `Papers` 폴더로 옮기는 걸
시도했는데, 291개를 일일이 손봐야 해서 번거로움 대비 이득이 크지 않다고 판단해 포기.
Zotero의 기본 managed storage(`storage\<key>\파일.pdf`)를 그대로 두고 그 폴더 자체를
Syncthing으로 동기화하는 쪽이 훨씬 간단하고, 결과적으로 얻는 것은 같다
(WebDAV 없이 두 컴퓨터 간 PDF 동기화).

## 최초 설정 (Windows, 완료됨)

1. `Desktop\Zotero_backup_YYYYMMDD\`에 마이그레이션 시도 전 원본 백업 보관 중 (안전망, 이제 참고용).
2. Syncthing 설치, 부팅 시 자동 실행되도록 시작프로그램에 등록.
3. Syncthing에 `Desktop\Zotero\storage`를 "Zotero Storage"라는 이름의 공유 폴더로 등록
   (폴더 아이디: `papers`, 파일 버전 관리: 휴지통 방식으로 이전 버전 보관).
4. Better BibTeX → 라이브러리 우클릭 → Export Library → 형식 Better BibTeX,
   "Keep updated" 체크, 저장 위치 `Desktop\paper_sjkim\bib\references.bib`. (완료)
5. Zotero → Settings → Sync → File Syncing → WebDAV 체크 해제 (계정 로그인/동기화는 유지). (확인 필요)

## 우분투 컴퓨터 설정 (처음 한 번)

```bash
sudo apt update && sudo apt install syncthing git -y   # zotero는 zotero.org tarball로 설치 권장
git clone https://github.com/sosejin-ust/paper_sjkim.git ~/paper_sjkim
```

1. Zotero 설치 후 같은 계정(`sojinkim_0512`)으로 로그인 → 서지 데이터 자동 동기화됨.
   데이터 디렉터리는 원하는 곳으로 지정 가능 (예: `~/Zotero`).
2. Better BibTeX 플러그인 설치 (전체 라이브러리가 이미 동기화되어 있으니 다시 export 설정할
   필요는 없음 — Windows 쪽 auto-export가 계속 `paper_sjkim` repo에 반영됨).
3. Syncthing 실행 → 웹 GUI(`http://127.0.0.1:8384`)에서 Windows 컴퓨터와 Device ID 교환.
   Windows Device ID: `DUI7YY4-7MUCYC7-UI3OWCU-DZKE6TQ-5DO3W6C-HMT5GNM-XNFD5MY-FEYHUQY`
4. Windows에서 새 기기 요청을 수락하고, "Zotero Storage" 폴더(아이디: `papers`)를
   우분투와 공유. 우분투 쪽 폴더 경로는 Zotero의 `storage\` 폴더로 지정
   (예: `~/Zotero/storage`).
5. Syncthing이 첫 동기화(1.2GB)를 끝낼 때까지 대기.

## 평소 사용법

작업 시작 전 / 끝난 후 한 번씩:

- Windows: `Desktop\paper_sjkim` 에서 `.\scripts\sync.ps1` 실행
- Ubuntu: `~/paper_sjkim` 에서 `./scripts/sync.sh` 실행

Zotero 서지 데이터와 Syncthing PDF는 각자 알아서 실시간/주기적으로 동기화되므로
따로 신경 쓸 필요 없음. `sync.ps1`/`sync.sh`는 `bib/references.bib`와 `notes/`만 다룬다.

## 새 논문 추가 워크플로

1. Zotero에 평소처럼 PDF 추가 (드래그 앤 드롭 등) — 지금까지 쓰던 방식 그대로.
2. Better BibTeX가 `references.bib`를 자동 갱신 (On Change, 5초 지연).
3. Syncthing이 새 PDF를 감지해서 다른 컴퓨터로 전송, `sync.ps1`/`sync.sh`가 bib/notes를
   다음 실행 때 동기화.

## 문제 생겼을 때

- PDF가 안 열리면: Syncthing이 해당 파일을 다 받았는지 `http://127.0.0.1:8384`에서 확인.
- 라이브러리가 꼬였으면: `Desktop\Zotero_backup_YYYYMMDD\`의 `zotero.sqlite`와
  `storage\`로 복구 가능 (Zotero 종료 후 덮어쓰기).
