import { useState } from 'react'
import { useNavigate, Link } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import './Auth.css'

function SignUp() {
  const navigate = useNavigate()
  const { signUp, loading, error } = useAuth()

  const [formData, setFormData] = useState({
    email: '',
    password: '',
    passwordConfirm: '',
    nickname: ''
  })
  const [formError, setFormError] = useState('')
  const [success, setSuccess] = useState(false)

  const handleChange = (e) => {
    const { name, value } = e.target
    setFormData(prev => ({ ...prev, [name]: value }))
    setFormError('')
  }

  const validateForm = () => {
    if (!formData.email || !formData.password || !formData.nickname) {
      setFormError('모든 필드를 입력해주세요')
      return false
    }

    if (formData.password.length < 6) {
      setFormError('비밀번호는 6자 이상이어야 합니다')
      return false
    }

    if (formData.password !== formData.passwordConfirm) {
      setFormError('비밀번호가 일치하지 않습니다')
      return false
    }

    if (formData.nickname.length < 2 || formData.nickname.length > 10) {
      setFormError('닉네임은 2-10자 사이여야 합니다')
      return false
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(formData.email)) {
      setFormError('올바른 이메일 형식을 입력해주세요')
      return false
    }

    return true
  }

  const handleSubmit = async (e) => {
    e.preventDefault()

    if (!validateForm()) return

    const result = await signUp(formData.email, formData.password, formData.nickname)

    if (result.success) {
      setSuccess(true)
    } else {
      let errorMsg = result.error
      if (errorMsg.includes('already registered')) {
        errorMsg = '이미 가입된 이메일입니다'
      }
      setFormError(errorMsg || '회원가입에 실패했습니다')
    }
  }

  if (success) {
    return (
      <div className="page auth-page">
        <div className="auth-container">
          <div className="auth-success">
            <span className="success-icon">✅</span>
            <h2>회원가입 완료!</h2>
            <p>이메일을 확인하여 계정을 활성화해주세요.</p>
            <Link to="/login" className="auth-link">
              로그인 페이지로 이동
            </Link>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="page auth-page">
      <div className="auth-container">
        <div className="auth-header">
          <h2>회원가입</h2>
          <p>청소년 커뮤니티에 가입하세요!</p>
        </div>

        <form onSubmit={handleSubmit} className="auth-form">
          <div className="form-group">
            <label htmlFor="email">이메일</label>
            <input
              type="email"
              id="email"
              name="email"
              value={formData.email}
              onChange={handleChange}
              placeholder="example@email.com"
              disabled={loading}
            />
          </div>

          <div className="form-group">
            <label htmlFor="nickname">닉네임</label>
            <input
              type="text"
              id="nickname"
              name="nickname"
              value={formData.nickname}
              onChange={handleChange}
              placeholder="2-10자 사이"
              maxLength={10}
              disabled={loading}
            />
          </div>

          <div className="form-group">
            <label htmlFor="password">비밀번호</label>
            <input
              type="password"
              id="password"
              name="password"
              value={formData.password}
              onChange={handleChange}
              placeholder="6자 이상"
              disabled={loading}
            />
          </div>

          <div className="form-group">
            <label htmlFor="passwordConfirm">비밀번호 확인</label>
            <input
              type="password"
              id="passwordConfirm"
              name="passwordConfirm"
              value={formData.passwordConfirm}
              onChange={handleChange}
              placeholder="비밀번호를 다시 입력"
              disabled={loading}
            />
          </div>

          {(formError || error) && (
            <div className="error-message">
              {formError || error}
            </div>
          )}

          <button
            type="submit"
            className="auth-btn"
            disabled={loading}
          >
            {loading ? '처리 중...' : '회원가입'}
          </button>
        </form>

        <div className="auth-footer">
          <p>
            이미 계정이 있으신가요?{' '}
            <Link to="/login" className="auth-link">로그인</Link>
          </p>
        </div>
      </div>
    </div>
  )
}

export default SignUp
