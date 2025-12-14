import { supabase } from './supabase'

// ============================================
// 게시글 CRUD
// ============================================

// 타임아웃 유틸리티
const withTimeout = (promise, ms = 10000) => {
  const timeout = new Promise((_, reject) =>
    setTimeout(() => reject(new Error('요청 시간 초과')), ms)
  )
  return Promise.race([promise, timeout])
}

// 게시글 목록 조회
export async function getPosts(options = {}) {
  const { type, limit = 20, offset = 0 } = options
  console.log('getPosts 시작, options:', options)

  try {
    let query = supabase
      .from('posts')
      .select('*')
      .order('created_at', { ascending: false })
      .range(offset, offset + limit - 1)

    if (type && type !== 'all') {
      query = query.eq('type', type)
    }

    console.log('posts 쿼리 실행 중...')

    // 10초 타임아웃 적용
    const { data, error } = await withTimeout(query, 10000)
    console.log('posts 쿼리 결과:', { data, error })

    if (error) {
      console.error('게시글 목록 조회 실패:', error)
      throw error
    }

    // 게시글이 없으면 빈 배열 반환
    if (!data || data.length === 0) {
      console.log('게시글 없음, 빈 배열 반환')
      return []
    }

    // 작성자 닉네임 가져오기
    const userIds = [...new Set(data.map(post => post.user_id))]
    const { data: profiles } = await supabase
      .from('profiles')
      .select('id, nickname')
      .in('id', userIds)

    const profileMap = {}
    if (profiles) {
      profiles.forEach(p => { profileMap[p.id] = p.nickname })
    }

    return data.map(post => ({
      ...post,
      author_nickname: profileMap[post.user_id] || '익명'
    }))
  } catch (err) {
    console.error('getPosts 에러:', err.message || err)
    throw err  // 에러를 던져서 UI에서 에러 상태 표시
  }
}

// 게시글 상세 조회
export async function getPost(postId) {
  const { data, error } = await supabase
    .from('posts')
    .select(`
      *,
      profiles:user_id (nickname, email)
    `)
    .eq('id', postId)
    .single()

  if (error) {
    console.error('게시글 조회 실패:', error)
    throw error
  }

  return {
    ...data,
    author_nickname: data.profiles?.nickname || '익명',
    author_email: data.profiles?.email
  }
}

// 게시글 작성
export async function createPost({ title, content, type, imageUrl }) {
  console.log('createPost 시작')

  const { data: { user }, error: userError } = await supabase.auth.getUser()
  console.log('현재 사용자:', user, userError)

  if (!user) {
    throw new Error('로그인이 필요합니다')
  }

  const postData = {
    user_id: user.id,
    title,
    content: content || '',
    type: type || 'general',
    image_url: imageUrl || null
  }
  console.log('저장할 데이터:', postData)

  const { data, error } = await supabase
    .from('posts')
    .insert(postData)
    .select()

  console.log('insert 결과:', data, error)

  if (error) {
    console.error('게시글 작성 실패:', error)
    throw error
  }

  return data?.[0] || data
}

// 게시글 수정
export async function updatePost(postId, { title, content, type, imageUrl }) {
  const { data, error } = await supabase
    .from('posts')
    .update({
      title,
      content,
      type,
      image_url: imageUrl,
      updated_at: new Date().toISOString()
    })
    .eq('id', postId)
    .select()
    .single()

  if (error) {
    console.error('게시글 수정 실패:', error)
    throw error
  }

  return data
}

// 게시글 삭제
export async function deletePost(postId) {
  const { error } = await supabase
    .from('posts')
    .delete()
    .eq('id', postId)

  if (error) {
    console.error('게시글 삭제 실패:', error)
    throw error
  }

  return true
}

// ============================================
// 댓글 CRUD
// ============================================

// 댓글 목록 조회
export async function getComments(postId) {
  const { data, error } = await supabase
    .from('comments')
    .select(`
      *,
      profiles:user_id (nickname, email)
    `)
    .eq('post_id', postId)
    .order('created_at', { ascending: true })

  if (error) {
    console.error('댓글 조회 실패:', error)
    throw error
  }

  return data.map(comment => ({
    ...comment,
    author_nickname: comment.profiles?.nickname || '익명',
    author_email: comment.profiles?.email
  }))
}

// 댓글 작성
export async function createComment(postId, content) {
  const { data: { user } } = await supabase.auth.getUser()

  if (!user) {
    throw new Error('로그인이 필요합니다')
  }

  const { data, error } = await supabase
    .from('comments')
    .insert({
      post_id: postId,
      user_id: user.id,
      content
    })
    .select(`
      *,
      profiles:user_id (nickname, email)
    `)
    .single()

  if (error) {
    console.error('댓글 작성 실패:', error)
    throw error
  }

  return {
    ...data,
    author_nickname: data.profiles?.nickname || '익명'
  }
}

// 댓글 삭제
export async function deleteComment(commentId) {
  const { error } = await supabase
    .from('comments')
    .delete()
    .eq('id', commentId)

  if (error) {
    console.error('댓글 삭제 실패:', error)
    throw error
  }

  return true
}

// ============================================
// 좋아요
// ============================================

// 좋아요 여부 확인
export async function checkLiked(postId) {
  const { data: { user } } = await supabase.auth.getUser()

  if (!user) return false

  const { data, error } = await supabase
    .from('likes')
    .select('id')
    .eq('post_id', postId)
    .eq('user_id', user.id)
    .maybeSingle()

  if (error) {
    console.error('좋아요 확인 실패:', error)
    return false
  }

  return !!data
}

// 좋아요 토글
export async function toggleLike(postId) {
  const { data: { user } } = await supabase.auth.getUser()

  if (!user) {
    throw new Error('로그인이 필요합니다')
  }

  // 기존 좋아요 확인
  const { data: existingLike } = await supabase
    .from('likes')
    .select('id')
    .eq('post_id', postId)
    .eq('user_id', user.id)
    .maybeSingle()

  if (existingLike) {
    // 좋아요 취소
    const { error } = await supabase
      .from('likes')
      .delete()
      .eq('id', existingLike.id)

    if (error) throw error
    return { liked: false }
  } else {
    // 좋아요 추가
    const { error } = await supabase
      .from('likes')
      .insert({
        post_id: postId,
        user_id: user.id
      })

    if (error) throw error
    return { liked: true }
  }
}

// 게시글의 좋아요 목록 (사용자 ID 목록)
export async function getPostLikes(postId) {
  const { data, error } = await supabase
    .from('likes')
    .select('user_id')
    .eq('post_id', postId)

  if (error) {
    console.error('좋아요 목록 조회 실패:', error)
    return []
  }

  return data.map(like => like.user_id)
}

// ============================================
// 유틸리티
// ============================================

// 상대 시간 포맷 (예: "30분 전")
export function formatRelativeTime(dateString) {
  const date = new Date(dateString)
  const now = new Date()
  const diffMs = now - date
  const diffSec = Math.floor(diffMs / 1000)
  const diffMin = Math.floor(diffSec / 60)
  const diffHour = Math.floor(diffMin / 60)
  const diffDay = Math.floor(diffHour / 24)

  if (diffSec < 60) return '방금 전'
  if (diffMin < 60) return `${diffMin}분 전`
  if (diffHour < 24) return `${diffHour}시간 전`
  if (diffDay < 7) return `${diffDay}일 전`

  return date.toLocaleDateString('ko-KR')
}

// 카테고리 이모지
export const POST_TYPE_EMOJI = {
  new: '🆕',
  review: '💬',
  event: '🎉',
  general: '📝'
}

// 카테고리 이름
export const POST_TYPE_NAME = {
  new: '신규 오픈',
  review: '후기',
  event: '이벤트',
  general: '자유'
}
