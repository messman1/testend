import { useState, useEffect } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import {
  getPost,
  getComments,
  createComment,
  deleteComment,
  deletePost,
  toggleLike,
  checkLiked,
  formatRelativeTime,
  POST_TYPE_EMOJI,
  POST_TYPE_NAME
} from '../services/postsApi'
import './PostDetail.css'

function PostDetail() {
  const { postId } = useParams()
  const navigate = useNavigate()
  const { user, isAuthenticated } = useAuth()

  const [post, setPost] = useState(null)
  const [comments, setComments] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  const [newComment, setNewComment] = useState('')
  const [submitting, setSubmitting] = useState(false)
  const [liked, setLiked] = useState(false)
  const [showMenu, setShowMenu] = useState(false)

  // 게시글 및 댓글 로드
  useEffect(() => {
    loadPostData()
  }, [postId])

  const loadPostData = async () => {
    setLoading(true)
    setError(null)

    try {
      const [postData, commentsData] = await Promise.all([
        getPost(postId),
        getComments(postId)
      ])

      setPost(postData)
      setComments(commentsData)

      // 좋아요 상태 확인
      if (isAuthenticated) {
        const isLiked = await checkLiked(postId)
        setLiked(isLiked)
      }
    } catch (err) {
      console.error('게시글 로드 실패:', err)
      setError('게시글을 불러오는데 실패했습니다.')
    } finally {
      setLoading(false)
    }
  }

  // 좋아요 토글
  const handleLike = async () => {
    if (!isAuthenticated) {
      if (confirm('로그인이 필요합니다. 로그인 페이지로 이동할까요?')) {
        navigate('/login')
      }
      return
    }

    try {
      const { liked: newLiked } = await toggleLike(postId)
      setLiked(newLiked)
      setPost({
        ...post,
        likes_count: post.likes_count + (newLiked ? 1 : -1)
      })
    } catch (err) {
      console.error('좋아요 실패:', err)
    }
  }

  // 댓글 작성
  const handleSubmitComment = async (e) => {
    e.preventDefault()

    if (!isAuthenticated) {
      if (confirm('로그인이 필요합니다. 로그인 페이지로 이동할까요?')) {
        navigate('/login')
      }
      return
    }

    if (!newComment.trim()) return

    setSubmitting(true)

    try {
      const comment = await createComment(postId, newComment.trim())
      setComments([...comments, comment])
      setPost({ ...post, comments_count: post.comments_count + 1 })
      setNewComment('')
    } catch (err) {
      console.error('댓글 작성 실패:', err)
      alert('댓글 작성에 실패했습니다.')
    } finally {
      setSubmitting(false)
    }
  }

  // 댓글 삭제
  const handleDeleteComment = async (commentId) => {
    if (!confirm('댓글을 삭제하시겠습니까?')) return

    try {
      await deleteComment(commentId)
      setComments(comments.filter(c => c.id !== commentId))
      setPost({ ...post, comments_count: post.comments_count - 1 })
    } catch (err) {
      console.error('댓글 삭제 실패:', err)
      alert('댓글 삭제에 실패했습니다.')
    }
  }

  // 게시글 삭제
  const handleDeletePost = async () => {
    if (!confirm('게시글을 삭제하시겠습니까?')) return

    try {
      await deletePost(postId)
      navigate('/community')
    } catch (err) {
      console.error('게시글 삭제 실패:', err)
      alert('게시글 삭제에 실패했습니다.')
    }
  }

  // 공유
  const handleShare = () => {
    navigator.clipboard.writeText(window.location.href)
    alert('링크가 복사되었습니다!')
  }

  if (loading) {
    return (
      <div className="page post-detail-page">
        <div className="loading-state">
          <span>🔄</span>
          <p>불러오는 중...</p>
        </div>
      </div>
    )
  }

  if (error || !post) {
    return (
      <div className="page post-detail-page">
        <div className="error-state">
          <span>⚠️</span>
          <p>{error || '게시글을 찾을 수 없습니다.'}</p>
          <button onClick={() => navigate('/community')}>목록으로</button>
        </div>
      </div>
    )
  }

  const isAuthor = user && post.user_id === user.id

  return (
    <div className="page post-detail-page">
      <div className="detail-header">
        <button className="back-btn" onClick={() => navigate('/community')}>
          ← 목록
        </button>
        {isAuthor && (
          <div className="menu-wrapper">
            <button
              className="menu-btn"
              onClick={() => setShowMenu(!showMenu)}
            >
              ⋮
            </button>
            {showMenu && (
              <div className="menu-dropdown">
                <button onClick={handleDeletePost}>🗑️ 삭제</button>
              </div>
            )}
          </div>
        )}
      </div>

      <article className="post-article">
        <div className="post-meta">
          <span className="post-type">
            {POST_TYPE_EMOJI[post.type]} {POST_TYPE_NAME[post.type]}
          </span>
          <span className="post-date">{formatRelativeTime(post.created_at)}</span>
        </div>

        <h1 className="post-title">{post.title}</h1>

        <div className="author-info">
          <div className="avatar">👤</div>
          <span className="author-name">{post.author_nickname}</span>
        </div>

        {post.content && (
          <div className="post-body">
            <p>{post.content}</p>
          </div>
        )}

        {post.image_url && (
          <div className="post-image">
            <img src={post.image_url} alt="게시글 이미지" />
          </div>
        )}

        <div className="post-stats">
          <button
            className={`stat-btn ${liked ? 'liked' : ''}`}
            onClick={handleLike}
          >
            {liked ? '❤️' : '🤍'} {post.likes_count}
          </button>
          <span className="stat-item">💬 {post.comments_count}</span>
          <button className="stat-btn" onClick={handleShare}>
            🔗 공유
          </button>
        </div>
      </article>

      <section className="comments-section">
        <h3>댓글 {comments.length}개</h3>

        <form className="comment-form" onSubmit={handleSubmitComment}>
          <input
            type="text"
            placeholder={isAuthenticated ? "댓글을 입력하세요..." : "로그인 후 댓글을 작성할 수 있습니다"}
            value={newComment}
            onChange={(e) => setNewComment(e.target.value)}
            disabled={!isAuthenticated || submitting}
          />
          <button
            type="submit"
            disabled={!isAuthenticated || !newComment.trim() || submitting}
          >
            {submitting ? '...' : '등록'}
          </button>
        </form>

        <div className="comments-list">
          {comments.length === 0 ? (
            <div className="no-comments">
              <p>아직 댓글이 없습니다.</p>
              <p>첫 번째 댓글을 남겨보세요!</p>
            </div>
          ) : (
            comments.map(comment => (
              <div key={comment.id} className="comment-item">
                <div className="comment-header">
                  <div className="comment-author">
                    <span className="avatar-small">👤</span>
                    <span className="name">{comment.author_nickname}</span>
                    <span className="time">{formatRelativeTime(comment.created_at)}</span>
                  </div>
                  {user && comment.user_id === user.id && (
                    <button
                      className="delete-btn"
                      onClick={() => handleDeleteComment(comment.id)}
                    >
                      🗑️
                    </button>
                  )}
                </div>
                <p className="comment-content">{comment.content}</p>
              </div>
            ))
          )}
        </div>
      </section>
    </div>
  )
}

export default PostDetail
