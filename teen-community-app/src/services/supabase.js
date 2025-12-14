import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  console.error('Supabase 환경 변수가 설정되지 않았습니다.')
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// ============================================
// 인증 관련 함수
// ============================================

// 회원가입 (이메일 + 비밀번호)
export async function signUp(email, password, nickname) {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: {
        nickname: nickname
      }
    }
  })

  if (error) throw error
  return data
}

// 로그인
export async function signIn(email, password) {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password
  })

  if (error) throw error
  return data
}

// 로그아웃
export async function signOut() {
  console.log('supabase signOut 함수 호출')
  try {
    // scope: 'local'로 로컬 세션만 삭제 (서버 요청 없이 빠르게 처리)
    const { error } = await supabase.auth.signOut({ scope: 'local' })
    console.log('supabase.auth.signOut 결과:', error ? error : '성공')
    if (error) throw error
  } catch (err) {
    console.error('signOut 내부 에러:', err)
    throw err
  }
}

// 현재 사용자 가져오기
export async function getCurrentUser() {
  const { data: { user } } = await supabase.auth.getUser()
  return user
}

// 세션 가져오기
export async function getSession() {
  const { data: { session } } = await supabase.auth.getSession()
  return session
}

// 인증 상태 변화 구독
export function onAuthStateChange(callback) {
  return supabase.auth.onAuthStateChange(callback)
}

// ============================================
// 프로필 관련 함수
// ============================================

// 프로필 조회
export async function getProfile(userId) {
  const { data, error } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', userId)
    .single()

  if (error && error.code !== 'PGRST116') throw error
  return data
}

// 프로필 생성/업데이트
export async function upsertProfile(profile) {
  const { data, error } = await supabase
    .from('profiles')
    .upsert(profile)
    .select()
    .single()

  if (error) throw error
  return data
}

// 프로필 업데이트
export async function updateProfile(userId, updates) {
  const { data, error } = await supabase
    .from('profiles')
    .update(updates)
    .eq('id', userId)
    .select()
    .single()

  if (error) throw error
  return data
}
