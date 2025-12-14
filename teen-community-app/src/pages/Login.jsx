import { useState } from 'react'
import { useNavigate, Link, useLocation } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import './Auth.css'

function Login() {
  const navigate = useNavigate()
  const location = useLocation()
  const { signIn, loading, error } = useAuth()

  const [formData, setFormData] = useState({
    email: '',
    password: ''
  })
  const [formError, setFormError] = useState('')

  const from = location.state?.from?.pathname || '/'

  const handleChange = (e) => {
    const { name, value } = e.target
    setFormData(prev => ({ ...prev, [name]: value }))
    setFormError('')
  }

  const handleSubmit = async (e) => {
    e.preventDefault()

    if (!formData.email || !formData.password) {
      setFormError('이메일과 비밀번호를 입력해주세요')
      return
    }

    const result = await signIn(formData.email, formData.password)

    if (result.success) {
      navigate(from, { replace: true })
    } else {
      let errorMsg = result.error
      if (errorMsg.includes('Invalid login credentials')) {
        errorMsg = '이메일 또는 비밀번호가 올바르지 않습니다'
      } else if (errorMsg.includes('Email not confirmed')) {
        errorMsg = '이메일 인증이 필요합니다. 이메일을 확인해주세요'
      }
      setFormError(errorMsg)
    }
  }

  return (
    <div className="page auth-page">
      <div className="auth-container">
        <div className="auth-header">
          <h2>로그인</h2>
          <p>다시 만나서 반가워요!</p>
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
            <label htmlFor="password">비밀번호</label>
            <input
              type="password"
              id="password"
              name="password"
              value={formData.password}
              onChange={handleChange}
              placeholder="비밀번호 입력"
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
            {loading ? '로그인 중...' : '로그인'}
          </button>
        </form>

        <div className="auth-footer">
          <p>
            계정이 없으신가요?{' '}
            <Link to="/signup" className="auth-link">회원가입</Link>
          </p>
        </div>
      </div>
    </div>
  )
}

export default Login
