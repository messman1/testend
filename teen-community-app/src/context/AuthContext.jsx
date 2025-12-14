import { createContext, useContext, useState, useEffect } from 'react'
import {
  supabase,
  signUp as supabaseSignUp,
  signIn as supabaseSignIn,
  signOut as supabaseSignOut,
  getProfile,
  updateProfile as supabaseUpdateProfile
} from '../services/supabase'

const AuthContext = createContext()

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null)
  const [profile, setProfile] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  // 초기 세션 확인 및 인증 상태 구독
  useEffect(() => {
    const initializeAuth = async () => {
      try {
        const { data: { session } } = await supabase.auth.getSession()

        if (session?.user) {
          setUser(session.user)
          try {
            const userProfile = await getProfile(session.user.id)
            setProfile(userProfile)
          } catch (err) {
            console.log('프로필 조회 실패 (테이블이 없을 수 있음):', err)
          }
        }
      } catch (err) {
        console.error('인증 초기화 오류:', err)
        setError(err.message)
      } finally {
        setLoading(false)
      }
    }

    initializeAuth()

    // 인증 상태 변화 구독
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        console.log('Auth state changed:', event)

        if (session?.user) {
          setUser(session.user)
          try {
            const userProfile = await getProfile(session.user.id)
            setProfile(userProfile)
          } catch (err) {
            console.log('프로필 조회 실패:', err)
          }
        } else {
          setUser(null)
          setProfile(null)
        }
        setLoading(false)
      }
    )

    return () => {
      subscription.unsubscribe()
    }
  }, [])

  // 회원가입
  const signUp = async (email, password, nickname) => {
    setError(null)
    setLoading(true)

    try {
      const data = await supabaseSignUp(email, password, nickname)
      return { success: true, data }
    } catch (err) {
      setError(err.message)
      return { success: false, error: err.message }
    } finally {
      setLoading(false)
    }
  }

  // 로그인
  const signIn = async (email, password) => {
    setError(null)
    setLoading(true)

    try {
      const data = await supabaseSignIn(email, password)
      return { success: true, data }
    } catch (err) {
      setError(err.message)
      return { success: false, error: err.message }
    } finally {
      setLoading(false)
    }
  }

  // 로그아웃
  const signOut = async () => {
    setError(null)
    console.log('AuthContext signOut 호출됨')

    try {
      await supabaseSignOut()
      console.log('Supabase signOut 완료')
      setUser(null)
      setProfile(null)
      console.log('상태 초기화 완료')
      return { success: true }
    } catch (err) {
      console.error('signOut 에러:', err)
      // 에러가 발생해도 로컬 상태는 초기화
      setUser(null)
      setProfile(null)
      setError(err.message)
      return { success: false, error: err.message }
    }
  }

  // 프로필 업데이트
  const updateProfile = async (updates) => {
    if (!user) return { success: false, error: '로그인이 필요합니다' }

    try {
      const updatedProfile = await supabaseUpdateProfile(user.id, updates)
      setProfile(updatedProfile)
      return { success: true, data: updatedProfile }
    } catch (err) {
      setError(err.message)
      return { success: false, error: err.message }
    }
  }

  // 인증 여부 확인
  const isAuthenticated = !!user

  const value = {
    user,
    profile,
    loading,
    error,
    isAuthenticated,
    signUp,
    signIn,
    signOut,
    updateProfile
  }

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return context
}

export default AuthContext
