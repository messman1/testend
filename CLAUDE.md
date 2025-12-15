# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

중학생들이 시험 후 건전하게 놀 수 있는 공간과 놀이를 발견하고, 친구들과 모임을 만드는 청소년 커뮤니티 플랫폼

**앱 이름**: 시험끝 오늘은 놀자!

**현재 상태**: React 웹 앱에서 Flutter 앱으로 마이그레이션 중

## 개발 명령어

### Flutter 앱 (teen_community_flutter)

**권장**: 현재 활발히 개발 중인 Flutter 앱을 사용하세요.

```bash
# Flutter 웹 개발 서버 실행
cd teen_community_flutter
flutter run -d chrome

# 의존성 설치
flutter pub get

# 분석 및 오류 검사
flutter analyze

# Android 앱 빌드
flutter build apk
```

### React 웹 앱 (teen-community-app)

**중요**: 모든 개발 명령어는 `teen-community-app` 디렉토리에서 실행해야 합니다.

```bash
# 개발 서버 실행 (http://localhost:3000)
cd teen-community-app
npm run dev

# 프로덕션 빌드
npm run build

# 빌드 결과 미리보기
npm run preview

# 의존성 설치
npm install

# Android 앱 빌드
npm run build && npx cap sync android
# 이후 Android Studio에서 Build > Build APK(s)
```

## 프로젝트 구조

### Flutter 앱 (teen_community_flutter)

```
testend/
├── teen_community_flutter/      # Flutter 앱 (현재 개발 중)
│   ├── lib/
│   │   ├── main.dart           # 앱 진입점
│   │   ├── config/             # 설정 (라우팅, 테마)
│   │   │   ├── routes/         # GoRouter 라우팅 설정
│   │   │   └── theme/          # Material 3 테마
│   │   ├── core/               # 공통 기능 (상수, 유틸)
│   │   └── features/           # 기능별 모듈
│   │       ├── auth/           # 인증
│   │       │   ├── data/       # Repository
│   │       │   ├── domain/     # Models
│   │       │   ├── providers/  # Riverpod Providers
│   │       │   └── presentation/ # Pages & Widgets
│   │       ├── location/       # GPS 위치 서비스
│   │       ├── places/         # 장소 검색 (카카오 API)
│   │       ├── explore/        # 탐색 페이지
│   │       ├── recommend/      # 추천 페이지
│   │       ├── meeting/        # 모임 기능
│   │       │   ├── data/       # meetings_repository.dart
│   │       │   ├── domain/     # meeting_model.dart
│   │       │   └── providers/  # meetings_provider.dart
│   │       ├── community/      # 커뮤니티 피드
│   │       │   ├── data/       # posts_repository.dart
│   │       │   ├── domain/     # post_model.dart
│   │       │   └── providers/  # posts_provider.dart
│   │       ├── profile/        # 프로필 & 북마크 & 친구
│   │       │   ├── data/       # bookmarks_repository.dart, friends_repository.dart
│   │       │   └── providers/  # bookmarks_provider.dart, friends_provider.dart
│   │       └── home/           # 홈 페이지
│   ├── supabase_schema.sql     # Supabase 데이터베이스 스키마
│   ├── SUPABASE_SETUP.md       # Supabase 설정 가이드
│   └── pubspec.yaml            # Flutter 의존성
├── teen-community-app/         # React 웹 앱 (레거시)
└── README.md
```

## 아키텍처

### Flutter 앱 아키텍처

- **상태 관리**: Riverpod (FutureProvider, StateNotifierProvider)
- **라우팅**: GoRouter (선언적 라우팅)
- **UI 프레임워크**: Material 3
- **아키텍처 패턴**: Clean Architecture (Data - Domain - Presentation)
  - **Data Layer**: Repository 패턴 (Supabase 통신)
  - **Domain Layer**: 모델 및 비즈니스 로직
  - **Presentation Layer**: Pages & Widgets

**주요 기능**:
- 📍 GPS 기반 위치 서비스 (Geolocator, 카카오 Geocoding)
- 🔍 장소 검색 (카카오 로컬 API)
- 👥 모임 생성/참가 (Supabase)
- 💬 커뮤니티 게시글/댓글/좋아요 (Supabase)
- 📌 북마크 기능 (Supabase)
- 👫 친구 관리 (Supabase)
- 🔐 인증 (Supabase Auth)

### React 웹 앱 아키텍처 (레거시)

- **라우터**: React Router DOM v7 사용
- **레이아웃**: `App.jsx`의 `Layout` 컴포넌트가 모든 페이지를 감싸며, 헤더와 하단 네비게이션 제공
- **페이지**: `src/pages/` 디렉토리에 각 탭별 페이지 컴포넌트 분리

**라우트 목록**:
- `/` - Home
- `/explore` - Explore (장소 탐색)
- `/recommend` - Recommend (추천, 홈에서 "오늘 뭐하지?" 버튼으로 접근)
- `/meeting` - Meeting (모임 목록)
- `/meeting/create` - Meeting (모임 생성, 동일 컴포넌트 재사용)
- `/community` - Community (소식 피드)
- `/community/write` - WritePost (글쓰기)
- `/community/post/:postId` - PostDetail (게시글 상세 + 댓글)
- `/profile` - Profile (내 프로필)
- `/login` - Login (로그인)
- `/signup` - SignUp (회원가입)
- `/place` - PlaceDetail (장소 상세 - 카카오맵 iframe)

### 네비게이션

하단 고정 네비게이션 바(Bottom Navigation)에 5개 탭:
1. 🏠 홈 - 메인 대시보드
2. 🔍 탐색 - 장소 검색
3. ➕ 모임 - 모임 생성/관리
4. 💬 소식 - 커뮤니티 피드
5. 👤 MY - 사용자 프로필

### 스타일링 (귀여운 강아지 컨셉)

- **스타일 방식**: CSS Modules 없이 일반 CSS 파일 사용
- **레이아웃**: Flexbox 기반의 모바일 우선 디자인
- **색상 팔레트**:
  - 메인 컬러: #F4A460 (샌디브라운)
  - 서브 컬러: #DEB887 (버리우드)
  - 텍스트: #8B5A2B (초콜릿 브라운)
  - 배경: #FFF8F0 (크림색)
  - 테두리: #F4D3B8 (연한 베이지)
- **반응형**: 모바일 중심 (최대 너비 480px)

## 기술 스택

- **React**: v19.2.3
- **React Router DOM**: v7.10.1
- **Vite**: v7.2.7 (빌드 도구)
- **@vitejs/plugin-react**: v5.1.2
- **Supabase**: 인증 및 데이터베이스
- **Capacitor**: v8.0.0 (Android 앱 변환)

## 인증 시스템 (Supabase)

### 환경 변수 (.env)
```
VITE_SUPABASE_URL=https://xlfglykiqrfjunptpelc.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGci...
```

### Supabase 테이블 구조

#### 1. profiles 테이블 (회원 프로필)
```sql
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT NOT NULL,
  nickname TEXT NOT NULL,
  level INTEGER DEFAULT 1,
  points INTEGER DEFAULT 0,
  badges TEXT[] DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public profiles are viewable by everyone" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);
```

#### 2. posts 테이블 (커뮤니티 게시글)
```sql
CREATE TABLE posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  content TEXT,
  type TEXT NOT NULL DEFAULT 'general',
  image_url TEXT,
  likes_count INTEGER DEFAULT 0,
  comments_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable read access for all users" ON posts FOR SELECT USING (true);
CREATE POLICY "Enable insert for authenticated users" ON posts FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Enable update for own posts" ON posts FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Enable delete for own posts" ON posts FOR DELETE USING (auth.uid() = user_id);
```

#### 3. comments 테이블 (댓글)
```sql
CREATE TABLE comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read comments" ON comments FOR SELECT USING (true);
CREATE POLICY "Authenticated users can create comments" ON comments FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own comments" ON comments FOR DELETE USING (auth.uid() = user_id);
```

#### 4. likes 테이블 (좋아요)
```sql
CREATE TABLE likes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(post_id, user_id)
);

ALTER TABLE likes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read likes" ON likes FOR SELECT USING (true);
CREATE POLICY "Authenticated users can create likes" ON likes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own likes" ON likes FOR DELETE USING (auth.uid() = user_id);
```

## Git 저장소

- Remote: https://github.com/messman1/testend.git
- Branch: master, feature/android-app

## 최근 작업 내역

### 2024-12-16 Flutter 마이그레이션 및 Supabase 통합 완료

#### 1차: Flutter 전면 마이그레이션

- **Flutter 앱으로 완전 마이그레이션**
  - React 웹 앱의 모든 기능을 Flutter로 재구현
  - Clean Architecture 패턴 적용 (Data - Domain - Presentation)
  - Riverpod을 이용한 상태 관리
  - GoRouter를 이용한 선언적 라우팅

- **Supabase 완전 통합**
  - 모임 기능: `meetings_repository.dart`, `meetings_provider.dart`
  - 커뮤니티 기능: `posts_repository.dart`, `posts_provider.dart`
  - 북마크 기능: `bookmarks_repository.dart`, `bookmarks_provider.dart`
  - 친구 기능: `friends_repository.dart`, `friends_provider.dart`
  - 인증 기능: `auth_repository.dart`, `auth_provider.dart`

- **코드 품질 개선**
  - Flutter analyze 오류 모두 수정
  - BuildContext async gap 경고 해결
  - 불필요한 non-null assertion 제거

#### 2차: 웹 플랫폼 iframe 지원 및 UI 개선

- **웹에서 앱 프레임 내 카카오맵 표시**
  - `dart:ui_web`의 `platformViewRegistry` 사용
  - `place_detail_web.dart`: 웹 전용 iframe 등록 함수
  - `place_detail_stub.dart`: 비웹 플랫폼용 stub
  - 조건부 import로 플랫폼별 코드 분리
  - 웹: HtmlElementView + iframe
  - 모바일: WebViewWidget
  - **장소 클릭 시 팝업이 아닌 앱 프레임 내에서 카카오맵 표시**

- **장소 썸네일 이미지 표시**
  - `CachedNetworkImage`로 장소 썸네일 표시
  - `PlaceModel.thumbnail` 필드 활용
  - 썸네일 없을 경우 카테고리 아이콘 fallback
  - 로딩 중 그라디언트 배경 + 로딩 인디케이터
  - 이미지 로드 실패 시 카테고리 아이콘으로 대체

- **Supabase 인증 개선**
  - `AuthFlowType.pkce` 명시적 설정
  - 웹 환경 인증 흐름 최적화
  - "missing or invalid authentication code" 에러 대응

- **UI/UX 개선**
  - ExplorePage: 장소 카드에 실제 이미지 또는 그라디언트 배너
  - Material 3 디자인 시스템 적용
  - 일관된 에러 처리 및 로딩 상태 표시

### 2024-12-14 (2차) - React 앱
- **GPS 기반 위치 서비스 구현**
  - LocationContext.jsx: GPS 위치 상태 관리
  - 브라우저 Geolocation API로 현재 위치 획득
  - 카카오 API로 좌표 → 동 이름 변환 (예: "역삼동")
  - 검색 반경 3km → 2km로 변경
  - 위치 새로고침 버튼 추가

- **장소 상세 페이지 (앱 내 iframe)**
  - PlaceDetail.jsx: 카카오맵 페이지를 iframe으로 표시
  - 장소 클릭 시 새 창이 아닌 앱 내에서 보기
  - 뒤로가기 버튼, 새 창 열기 버튼 제공

- **커뮤니티 기능 구현 (Supabase)**
  - postsApi.js: 게시글/댓글/좋아요 CRUD API
  - Community.jsx: 게시글 목록 (카테고리 필터링)
  - WritePost.jsx: 글쓰기 페이지
  - PostDetail.jsx: 게시글 상세 + 댓글 기능
  - 좋아요 토글, 댓글 작성/삭제
  - 로그인 사용자만 글쓰기/좋아요/댓글 가능

### 2024-12-14 (1차)
- **Supabase 회원가입/로그인 기능 구현**
  - AuthContext.jsx: 인증 상태 관리
  - supabase.js: Supabase 클라이언트 및 인증 함수
  - Login.jsx, SignUp.jsx: 로그인/회원가입 페이지
  - Profile.jsx: 로그인 상태에 따른 UI 분기, 로그아웃 기능

- **UI 테마 변경 (귀여운 강아지 컨셉)**
  - 색상 팔레트 전면 변경 (오렌지/베이지/브라운 계열)
  - 헤더 텍스트 변경: "🐶 시험끝 오늘은 놀자!"
  - 카드 및 버튼 border-radius 증가 (더 둥글게)

- **인기 카테고리 반응형 레이아웃**
  - grid → flexbox + flex-wrap으로 변경
  - 화면 크기에 따라 자동 줄바꿈

- **Android 앱 업데이트**
  - 앱 이름 변경: "시험끝 오늘은 놀자"
  - 앱 아이콘: 강아지 발바닥 모양 (오렌지 배경)
  - 하단 네비게이션 바와 시스템 네비게이션 겹침 수정
    - safe-area-inset-bottom 적용
    - fitsSystemWindows 설정

### 이전 작업
- Git 설정 완료 및 GitHub 저장소 연결
- 청소년 커뮤니티 앱 초기 프로젝트 구조 생성
- 6개 주요 페이지 컴포넌트 구현 (Home, Explore, Recommend, Meeting, Community, Profile)
- 하단 네비게이션 바를 통한 라우팅 구현
- 카카오 API 연동 (장소 검색)
- Capacitor를 사용한 Android 앱 변환 설정

## 다음 단계

### 우선순위 1: Supabase 데이터베이스 설정 (필수)

- **데이터베이스 설정**
  - `supabase_schema.sql` 실행하여 테이블 생성
  - RLS 정책 및 RPC 함수 설정
  - 테스트 데이터 입력
  - **Redirect URLs 설정** (인증 오류 해결):
    - http://localhost:*
    - http://127.0.0.1:*

- **인증 문제 해결**
  - "missing or invalid authentication code" 에러 디버깅
  - Supabase Dashboard에서 Email Confirm OFF 확인
  - 브라우저 Console 로그 확인

### 우선순위 2: 기능 개선

- **이미지 관리**
  - 프로필 이미지 업로드 기능 (Supabase Storage)
  - 게시글 이미지 업로드
  - 카카오 Places API 대안 이미지 소스 (Google Places API 또는 직접 관리)

- **실시간 기능**
  - 실시간 알림 (Supabase Realtime)
  - 새 게시글/댓글 실시간 업데이트

- **검색 개선**
  - 전체 검색 기능 (장소 + 게시글 + 사용자)
  - 검색 히스토리 저장

### 우선순위 3: 배포

- **Android 앱**
  - APK 빌드 및 테스트
  - Google Play 배포 준비

- **웹 앱**
  - Firebase Hosting 또는 Vercel 배포
  - 프로덕션 환경 변수 설정

- **iOS 앱** (추후)
  - iOS 빌드 환경 설정
  - App Store 배포 준비

### 기술 부채

- 오프라인 지원 (Hive를 이용한 로컬 캐싱)
- 접근성 개선 (Semantics 위젯 추가)
- 성능 최적화 (이미지 최적화, 리스트 가상화)
- 테스트 코드 작성 (단위 테스트, 위젯 테스트)
