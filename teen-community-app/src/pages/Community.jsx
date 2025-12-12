import { useState } from 'react'
import './Community.css'

function Community() {
  const [activeFilter, setActiveFilter] = useState('all')

  const posts = [
    {
      id: 1,
      type: 'new',
      title: '🆕 강남역에 보드게임 카페 새로 생겼어요!',
      author: '지민',
      time: '30분 전',
      likes: 24,
      comments: 5,
      image: '🎲'
    },
    {
      id: 2,
      type: 'review',
      title: '방탈출 카페 완전 재밌어!',
      content: '친구들이랑 미스터리 테마 했는데 완전 몰입됨! 난이도도 적당하고 힌트도 잘 주심',
      author: '민지',
      time: '1시간 전',
      likes: 45,
      comments: 12,
      image: '🎯'
    },
    {
      id: 3,
      type: 'event',
      title: '🎉 CGV 청소년 할인 이벤트',
      content: '이번 주말까지 중학생 50% 할인!',
      author: '관리자',
      time: '3시간 전',
      likes: 89,
      comments: 23,
      image: '🎬'
    },
    {
      id: 4,
      type: 'review',
      title: '엽기떡볶이 먹방 성공',
      content: '친구들 5명이서 먹었는데 양도 많고 맛있어요 👍',
      author: '수지',
      time: '5시간 전',
      likes: 31,
      comments: 8,
      image: '🍜'
    }
  ]

  const filteredPosts = activeFilter === 'all'
    ? posts
    : posts.filter(post => post.type === activeFilter)

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

      <div className="posts-list">
        {filteredPosts.map(post => (
          <div key={post.id} className="post-card">
            <div className="post-header">
              <div className="author-info">
                <div className="avatar">👤</div>
                <div>
                  <div className="author-name">{post.author}</div>
                  <div className="post-time">{post.time}</div>
                </div>
              </div>
              <button className="post-menu">⋮</button>
            </div>

            <div className="post-content">
              <h3>{post.title}</h3>
              {post.content && <p>{post.content}</p>}
              {post.image && (
                <div className="post-image">
                  <div className="image-placeholder">{post.image}</div>
                </div>
              )}
            </div>

            <div className="post-actions">
              <button className="post-action-btn">
                ❤️ {post.likes}
              </button>
              <button className="post-action-btn">
                💬 {post.comments}
              </button>
              <button className="post-action-btn">
                🔗 공유
              </button>
            </div>
          </div>
        ))}
      </div>

      <button className="floating-write-btn">✏️</button>
    </div>
  )
}

export default Community
