import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import { getPosts, toggleLike, formatRelativeTime, POST_TYPE_EMOJI } from '../services/postsApi'
import './Community.css'

function Community() {
  const navigate = useNavigate()
  const { user, isAuthenticated } = useAuth()
  const [activeFilter, setActiveFilter] = useState('all')
  const [posts, setPosts] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  // 게시글 로드
  useEffect(() => {
    loadPosts()
  }, [activeFilter])

  const loadPosts = async () => {
    setLoading(true)
    setError(null)

    try {
      const data = await getPosts({
        type: activeFilter === 'all' ? null : activeFilter
      })
      setPosts(data)
    } catch (err) {
      console.error('게시글 로드 실패:', err)
      setError('게시글을 불러오는데 실패했습니다.')
    } finally {
      setLoading(false)
    }
  }

  // 좋아요 토글
  const handleLike = async (e, postId) => {
    e.stopPropagation()

    if (!isAuthenticated) {
      if (confirm('로그인이 필요합니다. 로그인 페이지로 이동할까요?')) {
        navigate('/login')
      }
      return
    }

    try {
      const { liked } = await toggleLike(postId)
      // 로컬 상태 업데이트
      setPosts(posts.map(post =>
        post.id === postId
          ? { ...post, likes_count: post.likes_count + (liked ? 1 : -1) }
          : post
      ))
    } catch (err) {
      console.error('좋아요 실패:', err)
    }
  }

  // 글쓰기 버튼
  const handleWrite = () => {
    if (!isAuthenticated) {
      if (confirm('로그인이 필요합니다. 로그인 페이지로 이동할까요?')) {
        navigate('/login')
      }
      return
    }
    navigate('/community/write')
  }

  // 게시글 클릭
  const handlePostClick = (postId) => {
    navigate(`/community/post/${postId}`)
  }

  return (
    <div className="page community-page">
      <div className="community-header">
        <h2>소식 & 커뮤니티</h2>
      </div>

      <div className="filter-tabs">
        <button
          className={`filter-tab ${activeFilter === 'all' ? 'active' : ''}`}
          onClick={() => setActiveFilter('all')}
        >
          전체
        </button>
        <button
          className={`filter-tab ${activeFilter === 'new' ? 'active' : ''}`}
          onClick={() => setActiveFilter('new')}
        >
          🆕 신규 오픈
        </button>
        <button
          className={`filter-tab ${activeFilter === 'review' ? 'active' : ''}`}
          onClick={() => setActiveFilter('review')}
        >
          💬 후기
        </button>
        <button
          className={`filter-tab ${activeFilter === 'event' ? 'active' : ''}`}
          onClick={() => setActiveFilter('event')}
        >
          🎉 이벤트
        </button>
      </div>

      {loading && (
        <div className="loading-state">
          <span>🔄</span>
          <p>게시글을 불러오는 중...</p>
        </div>
      )}

      {error && (
        <div className="error-state">
          <span>⚠️</span>
          <p>{error}</p>
          <button onClick={loadPosts}>다시 시도</button>
        </div>
      )}

      {!loading && !error && posts.length === 0 && (
        <div className="empty-state">
          <span>📝</span>
          <p>아직 게시글이 없습니다.</p>
          <p>첫 번째 글을 작성해보세요!</p>
        </div>
      )}

      {!loading && !error && posts.length > 0 && (
        <div className="posts-list">
          {posts.map(post => (
            <div
              key={post.id}
              className="post-card"
              onClick={() => handlePostClick(post.id)}
            >
              <div className="post-header">
                <div className="author-info">
                  <div className="avatar">👤</div>
                  <div>
                    <div className="author-name">{post.author_nickname}</div>
                    <div className="post-time">{formatRelativeTime(post.created_at)}</div>
                  </div>
                </div>
                <span className="post-type-badge">
                  {POST_TYPE_EMOJI[post.type]}
                </span>
              </div>

              <div className="post-content">
                <h3>{post.title}</h3>
                {post.content && <p>{post.content}</p>}
                {post.image_url && (
                  <div className="post-image">
                    <img src={post.image_url} alt="게시글 이미지" />
                  </div>
                )}
              </div>

              <div className="post-actions">
                <button
                  className="post-action-btn"
                  onClick={(e) => handleLike(e, post.id)}
                >
                  ❤️ {post.likes_count}
                </button>
                <button className="post-action-btn">
                  💬 {post.comments_count}
                </button>
                <button
                  className="post-action-btn"
                  onClick={(e) => {
                    e.stopPropagation()
                    navigator.clipboard.writeText(window.location.origin + `/community/post/${post.id}`)
                    alert('링크가 복사되었습니다!')
                  }}
                >
                  🔗 공유
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      <button className="floating-write-btn" onClick={handleWrite}>
        ✏️
      </button>
    </div>
  )
}

export default Community
