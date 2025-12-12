# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

중학생들이 시험 후 건전하게 놀 수 있는 공간과 놀이를 발견하고, 친구들과 모임을 만드는 청소년 커뮤니티 플랫폼

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
│   │   └── pages/              # 페이지 컴포넌트들
│   │       ├── Home.jsx        # 홈 - 인기 카테고리 및 빠른 액션
│   │       ├── Explore.jsx     # 탐색 - 장소 검색 및 필터링
│   │       ├── Recommend.jsx   # 추천 - "오늘 뭐하지?" 맞춤 추천
│   │       ├── Meeting.jsx     # 모임 - 친구들과 모임 만들기
│   │       ├── Community.jsx   # 소식 - 커뮤니티 피드
│   │       └── Profile.jsx     # 프로필 - 내 활동 통계 및 뱃지
│   ├── public/
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

### 네비게이션

하단 고정 네비게이션 바(Bottom Navigation)에 5개 탭:
1. 🏠 홈 - 메인 대시보드
2. 🔍 탐색 - 장소 검색
3. ➕ 모임 - 모임 생성/관리
4. 💬 소식 - 커뮤니티 피드
5. 👤 MY - 사용자 프로필

### 스타일링

- **스타일 방식**: CSS Modules 없이 일반 CSS 파일 사용
- **레이아웃**: Flexbox 기반의 모바일 우선 디자인
- **색상**: 밝고 친근한 파스텔 톤 사용 (#ff6b6b, #4ecdc4, #ffe66d, #a8e6cf, #ffd3b6)
- **반응형**: 모바일 중심 (최대 너비 600px)

## 기술 스택

- **React**: v19.2.3
- **React Router DOM**: v7.10.1
- **Vite**: v7.2.7 (빌드 도구)
- **@vitejs/plugin-react**: v5.1.2

## Git 저장소

- Remote: https://github.com/messman1/testend.git
- Branch: master

## 최근 작업 내역

- Git 설정 완료 및 GitHub 저장소 연결
- 청소년 커뮤니티 앱 초기 프로젝트 구조 생성
- 6개 주요 페이지 컴포넌트 구현 (Home, Explore, Recommend, Meeting, Community, Profile)
- 하단 네비게이션 바를 통한 라우팅 구현

## 다음 단계

실제 기능 구현이 필요한 영역:
- 각 페이지의 실제 데이터 연동 및 상태 관리
- 백엔드 API 연동
- 사용자 인증 시스템
- 장소 검색 및 필터링 로직
- 모임 생성 및 관리 기능
- 커뮤니티 피드 및 댓글 시스템
