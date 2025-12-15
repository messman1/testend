-- 친구 관계 테이블
CREATE TABLE IF NOT EXISTS public.friends (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  friend_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- 한 사용자가 같은 친구를 중복으로 추가할 수 없도록 UNIQUE 제약조건
  UNIQUE(user_id, friend_id),

  -- 자기자신을 친구로 추가할 수 없도록 제약조건
  CHECK (user_id != friend_id)
);

-- 친구 요청 테이블
CREATE TABLE IF NOT EXISTS public.friend_requests (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  from_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  to_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- 같은 사람에게 중복 요청 방지
  UNIQUE(from_user_id, to_user_id),

  -- 자기자신에게 요청할 수 없도록 제약조건
  CHECK (from_user_id != to_user_id)
);

-- Row Level Security 활성화
ALTER TABLE public.friends ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.friend_requests ENABLE ROW LEVEL SECURITY;

-- friends 테이블 정책
-- 자신의 친구 목록 조회 가능
CREATE POLICY "Users can view their own friends"
  ON public.friends FOR SELECT
  USING (auth.uid() = user_id OR auth.uid() = friend_id);

-- 자신의 친구 추가 가능
CREATE POLICY "Users can add their own friends"
  ON public.friends FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 자신의 친구 삭제 가능
CREATE POLICY "Users can delete their own friends"
  ON public.friends FOR DELETE
  USING (auth.uid() = user_id);

-- friend_requests 테이블 정책
-- 자신이 보낸 요청 또는 받은 요청만 조회 가능
CREATE POLICY "Users can view their friend requests"
  ON public.friend_requests FOR SELECT
  USING (auth.uid() = from_user_id OR auth.uid() = to_user_id);

-- 친구 요청 보내기 가능
CREATE POLICY "Users can send friend requests"
  ON public.friend_requests FOR INSERT
  WITH CHECK (auth.uid() = from_user_id);

-- 자신이 받은 요청만 업데이트 가능 (수락/거절)
CREATE POLICY "Users can update received requests"
  ON public.friend_requests FOR UPDATE
  USING (auth.uid() = to_user_id);

-- 자신이 보낸 요청만 삭제 가능
CREATE POLICY "Users can delete sent requests"
  ON public.friend_requests FOR DELETE
  USING (auth.uid() = from_user_id);

-- 인덱스 생성 (성능 최적화)
CREATE INDEX IF NOT EXISTS idx_friends_user_id ON public.friends(user_id);
CREATE INDEX IF NOT EXISTS idx_friends_friend_id ON public.friends(friend_id);
CREATE INDEX IF NOT EXISTS idx_friend_requests_from_user ON public.friend_requests(from_user_id);
CREATE INDEX IF NOT EXISTS idx_friend_requests_to_user ON public.friend_requests(to_user_id);
CREATE INDEX IF NOT EXISTS idx_friend_requests_status ON public.friend_requests(status);
