import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import { createPost, POST_TYPE_NAME } from '../services/postsApi'
import './WritePost.css'

function WritePost() {
  const navigate = useNavigate()
  const { isAuthenticated } = useAuth()

  const [title, setTitle] = useState('')
  const [content, setContent] = useState('')
  const [type, setType] = useState('general')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)

  // 로그인 체크
  if (!isAuthenticated) {
    return (
      <div className="page write-post-page">
        <div className="login-required">
          <span>🔒</span>
          <p>로그인이 필요합니다.</p>
          <button onClick={() => navigate('/login')}>로그인하기</button>
        </div>
      </div>
    )
  }

  const handleSubmit = async (e) => {
    e.preventDefault()

    if (!title.trim()) {
      setError('제목을 입력해주세요.')
      return
    }

    setLoading(true)
    setError(null)

    try {
      await createPost({
        title: title.trim(),
        content: content.trim(),
        type
      })

      // 성공 시 목록으로 이동
      navigate('/community')
    } catch (err) {
      console.error('게시글 작성 실패:', err)
      setError('게시글 작성에 실패했습니다. 다시 시도해주세요.')
    } finally {
      setLoading(false)
    }
  }

  const handleBack = () => {
    if (title || content) {
      if (confirm('작성 중인 내용이 있습니다. 나가시겠습니까?')) {
        navigate(-1)
      }
    } else {
      navigate(-1)
    }
  }

  return (
    <div className="page write-post-page">
      <div className="write-header">
        <button className="back-btn" onClick={handleBack}>
          ← 취소
        </button>
        <h2>글쓰기</h2>
        <button
          className="submit-btn"
          onClick={handleSubmit}
          disabled={loading || !title.trim()}
        >
          {loading ? '작성 중...' : '완료'}
        </button>
      </div>

      <form className="write-form" onSubmit={handleSubmit}>
        {error && (
          <div className="error-message">
            ⚠️ {error}
          </div>
        )}

        <div className="type-selector">
          <label>카테고리</label>
          <div className="type-buttons">
            {Object.entries(POST_TYPE_NAME).map(([key, name]) => (
              <button
                key={key}
                type="button"
                className={`type-btn ${type === key ? 'active' : ''}`}
                onClick={() => setType(key)}
              >
                {key === 'new' && '🆕 '}
                {key === 'review' && '💬 '}
                {key === 'event' && '🎉 '}
                {key === 'general' && '📝 '}
                {name}
              </button>
            ))}
          </div>
        </div>

        <div className="input-group">
          <input
            type="text"
            placeholder="제목을 입력하세요"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            maxLength={100}
            className="title-input"
          />
          <span className="char-count">{title.length}/100</span>
        </div>

        <div className="input-group">
          <textarea
            placeholder="내용을 입력하세요 (선택)"
            value={content}
            onChange={(e) => setContent(e.target.value)}
            maxLength={2000}
            rows={10}
            className="content-input"
          />
          <span className="char-count">{content.length}/2000</span>
        </div>
      </form>
    </div>
  )
}

export default WritePost
