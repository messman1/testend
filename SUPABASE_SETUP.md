# Supabase 연동 가이드

Flutter 앱에서 Supabase를 연동하는 방법입니다.

## 1. Supabase SQL 스키마 실행

Supabase 대시보드에서 SQL Editor를 열고, `supabase_schema.sql` 파일의 내용을 실행하세요.

이 스키마는 다음 테이블들을 생성합니다:
- **posts**: 커뮤니티 게시글
- **comments**: 댓글
- **likes**: 좋아요
- **meetings**: 모임
- **bookmarks**: 북마크
- **friends**: 친구

## 2. 환경 변수 확인

`.env` 파일에 Supabase URL과 Anon Key가 올바르게 설정되어 있는지 확인하세요:

```env
VITE_SUPABASE_URL=https://xlfglykiqrfjunptpelc.supabase.co
VITE_SUPABASE_ANON_KEY=your_anon_key_here
```

## 3. 구현된 기능

### ✅ 커뮤니티 (완전 연동)
- 게시글 목록 조회 (타입별 필터링)
- 게시글 작성
- 게시글 상세 조회
- 댓글 작성/조회
- 좋아요 토글
- Pull-to-refresh 지원

**파일:**
- `lib/features/community/data/posts_repository.dart`
- `lib/features/community/providers/posts_provider.dart`
- `lib/features/community/presentation/pages/community_page.dart`
- `lib/features/community/presentation/pages/write_post_page.dart`
- `lib/features/community/presentation/pages/post_detail_page.dart`

### ✅ 모임 (Repository/Provider 구현 완료)
- 모임 목록 조회 (카테고리별 필터링)
- 모임 생성
- 모임 참가/탈퇴
- 모임 삭제

**파일:**
- `lib/features/meeting/data/meetings_repository.dart`
- `lib/features/meeting/providers/meetings_provider.dart`
- `lib/features/meeting/presentation/pages/meeting_page.dart` (업데이트 필요)

### 🔄 북마크 (TODO)
북마크 기능은 아직 구현되지 않았습니다. 다음 작업:
1. `lib/features/bookmarks/data/bookmarks_repository.dart` 생성
2. `lib/features/bookmarks/providers/bookmarks_provider.dart` 생성
3. `lib/features/profile/presentation/pages/bookmarked_page.dart` 업데이트

### 🔄 친구 (TODO)
친구 기능은 아직 구현되지 않았습니다. 다음 작업:
1. `lib/features/friends/data/friends_repository.dart` 생성
2. `lib/features/friends/providers/friends_provider.dart` 생성
3. `lib/features/profile/presentation/pages/friends_page.dart` 업데이트

## 4. 테스트 방법

### 커뮤니티 기능 테스트
1. 앱 실행 후 로그인
2. "소식" 탭으로 이동
3. "글쓰기" 버튼 클릭
4. 게시글 작성
5. 게시글 클릭하여 상세보기
6. 좋아요 및 댓글 작성

### 모임 기능 테스트
1. "모임" 탭으로 이동
2. "모임 만들기" 버튼 클릭
3. 모임 정보 입력 후 생성
4. 다른 사용자 계정으로 로그인
5. 생성된 모임에 참가

## 5. 알려진 이슈

- MeetingPage가 아직 Supabase Provider를 사용하도록 업데이트되지 않음
- 북마크 및 친구 기능이 미구현 상태
- 이미지 업로드 기능 미구현 (Supabase Storage 연동 필요)

## 6. 다음 단계

1. MeetingPage를 `meetingsProvider` 사용하도록 리팩토링
2. 북마크 Repository/Provider 구현
3. 친구 Repository/Provider 구현
4. Supabase Storage로 이미지 업로드 기능 추가
5. 실시간 업데이트 (Supabase Realtime) 추가

## 7. 추가 RPC 함수

스키마에 이미 포함되어 있지만, 필요한 RPC 함수들:

- `increment_likes_count(post_id UUID)`: 좋아요 수 증가
- `decrement_likes_count(post_id UUID)`: 좋아요 수 감소
- `increment_comments_count(post_id UUID)`: 댓글 수 증가
- `decrement_comments_count(post_id UUID)`: 댓글 수 감소
