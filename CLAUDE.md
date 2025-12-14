# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

중학생들이 시험 후 건전하게 놀 수 있는 공간과 놀이를 발견하고, 친구들과 모임을 만드는 청소년 커뮤니티 플랫폼

**앱 이름**: 시험끝 오늘은 놀자!

## 개발 명령어

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

```
testend/
├── teen-community-app/          # 실제 애플리케이션 코드
│   ├── src/
│   │   ├── main.jsx            # 앱 진입점
│   │   ├── App.jsx             # 라우팅 및 레이아웃 정의
│   │   ├── App.css             # 전역 스타일 및 레이아웃
│   │   ├── index.css           # 기본 CSS 리셋
│   │   ├── pages/              # 페이지 컴포넌트들
│   │   │   ├── Home.jsx        # 홈 - 인기 카테고리 및 빠른 액션
│   │   │   ├── Explore.jsx     # 탐색 - 장소 검색 및 필터링
│   │   │   ├── Recommend.jsx   # 추천 - "오늘 뭐하지?" 맞춤 추천
│   │   │   ├── Meeting.jsx     # 모임 - 친구들과 모임 만들기
│   │   │   ├── Community.jsx   # 소식 - 커뮤니티 피드
│   │   │   ├── Profile.jsx     # 프로필 - 내 활동 통계 및 뱃지
│   │   │   ├── Login.jsx       # 로그인 페이지
│   │   │   └── SignUp.jsx      # 회원가입 페이지
│   │   ├── services/
│   │   │   ├── kakaoApi.js     # 카카오 로컬 API 서비스
│   │   │   └── supabase.js     # Supabase 클라이언트 및 인증 함수
│   │   └── context/
│   │       ├── MeetingContext.jsx  # 모임 상태 관리
│   │       └── AuthContext.jsx     # 인증 상태 관리
│   ├── android/                # Android 네이티브 프로젝트 (Capacitor)
│   ├── .env                    # 환경 변수 (Supabase 키)
│   ├── capacitor.config.json   # Capacitor 설정
│   ├── vite.config.js
│   └── package.json
├── README.md
├── .gitignore
└── 청소년_커뮤니티_앱_기획서.md
```

## 아키텍처

### 라우팅 구조

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
- `/profile` - Profile (내 프로필)
- `/login` - Login (로그인)
- `/signup` - SignUp (회원가입)

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
profiles 테이블이 필요합니다. Supabase SQL Editor에서 실행:
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

CREATE POLICY "Public profiles are viewable by everyone"
  ON public.profiles FOR SELECT USING (true);

CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);
```

## Git 저장소

- Remote: https://github.com/messman1/testend.git
- Branch: master, feature/android-app

## 최근 작업 내역

### 2024-12-14
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

- 커뮤니티 피드 실제 데이터 연동 (Supabase)
- 모임 데이터 Supabase 연동 (현재 localStorage)
- 프로필 이미지 업로드 기능
- 친구 시스템 구현
- 푸시 알림 설정
