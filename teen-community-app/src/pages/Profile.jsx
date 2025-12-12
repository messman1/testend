import './Profile.css'

function Profile() {
  const user = {
    name: '홍길동',
    nickname: '놀이왕',
    level: 5,
    points: 1250,
    badges: ['🎯 방탈출 마스터', '🍜 맛집 헌터', '👥 모임왕']
  }

  const stats = [
    { label: '다녀온 장소', value: 24, icon: '📍' },
    { label: '참여한 모임', value: 15, icon: '👥' },
    { label: '작성한 후기', value: 18, icon: '✏️' }
  ]

  const visitedPlaces = [
    { name: '미스터리 방탈출', category: '방탈출', date: '2025-01-15' },
    { name: 'CGV 강남점', category: '영화관', date: '2025-01-10' },
    { name: '엽기떡볶이', category: '먹거리', date: '2025-01-08' }
  ]

  return (
    <div className="page profile-page">
      <div className="profile-header">
        <div className="profile-avatar">👤</div>
        <h2>{user.name}</h2>
        <p className="nickname">@{user.nickname}</p>
        <div className="level-badge">Lv. {user.level}</div>
      </div>

      <div className="points-section">
        <div className="points-card">
          <span className="points-icon">⭐</span>
          <div>
            <div className="points-label">포인트</div>
            <div className="points-value">{user.points}P</div>
          </div>
        </div>
      </div>

      <div className="badges-section">
        <h3>내 뱃지</h3>
        <div className="badges-grid">
          {user.badges.map((badge, index) => (
            <div key={index} className="badge-card">
              {badge}
            </div>
          ))}
        </div>
      </div>

      <div className="stats-section">
        <h3>활동 통계</h3>
        <div className="stats-grid">
          {stats.map((stat, index) => (
            <div key={index} className="stat-card">
              <div className="stat-icon">{stat.icon}</div>
              <div className="stat-value">{stat.value}</div>
              <div className="stat-label">{stat.label}</div>
            </div>
          ))}
        </div>
      </div>

      <div className="history-section">
        <h3>최근 다녀온 곳</h3>
        <div className="history-list">
          {visitedPlaces.map((place, index) => (
            <div key={index} className="history-item">
              <div className="history-info">
                <h4>{place.name}</h4>
                <p>{place.category} · {place.date}</p>
              </div>
              <button className="review-btn">후기 쓰기</button>
            </div>
          ))}
        </div>
        <button className="view-all-btn">전체 보기</button>
      </div>

      <div className="menu-section">
        <button className="menu-item">
          <span>📋</span>
          <span>찜한 장소</span>
          <span className="arrow">›</span>
        </button>
        <button className="menu-item">
          <span>👥</span>
          <span>친구 관리</span>
          <span className="arrow">›</span>
        </button>
        <button className="menu-item">
          <span>⚙️</span>
          <span>설정</span>
          <span className="arrow">›</span>
        </button>
      </div>
    </div>
  )
}

export default Profile
