import { useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import './Profile.css'

function Profile() {
  const navigate = useNavigate()
  const { user, profile, isAuthenticated, signOut, loading } = useAuth()

  // 로그아웃 처리
  const handleLogout = async () => {
    console.log('로그아웃 버튼 클릭됨')
    try {
      const result = await signOut()
      console.log('로그아웃 결과:', result)
      navigate('/')
    } catch (err) {
      console.error('로그아웃 에러:', err)
    }
  }

  // 로딩 중 (초기 로딩만)
  if (loading && !user) {
    return (
      <div className="page profile-page">
        <div className="loading-text">불러오는 중...</div>
      </div>
    )
  }

  // 비로그인 상태일 때
  if (!isAuthenticated) {
    return (
      <div className="page profile-page">
        <div className="profile-header">
          <div className="profile-avatar">👤</div>
          <h2>로그인이 필요합니다</h2>
          <p className="nickname">커뮤니티에 참여하려면 로그인하세요</p>
        </div>

        <div className="auth-actions">
          <button
            type="button"
            className="auth-action-btn primary"
            onClick={() => navigate('/login')}
          >
            로그인
          </button>
          <button
            type="button"
            className="auth-action-btn"
            onClick={() => navigate('/signup')}
          >
            회원가입
          </button>
        </div>
      </div>
    )
  }

  // 프로필 데이터 구성
  const displayProfile = {
    name: profile?.nickname || user?.user_metadata?.nickname || '사용자',
    nickname: profile?.nickname || user?.user_metadata?.nickname || user?.email?.split('@')[0] || '익명',
    email: user?.email || '',
    level: profile?.level || 1,
    points: profile?.points || 0,
    badges: profile?.badges || []
  }

  const stats = [
    { label: '다녀온 장소', value: 0, icon: '📍' },
    { label: '참여한 모임', value: 0, icon: '👥' },
    { label: '작성한 후기', value: 0, icon: '✏️' }
  ]

  return (
    <div className="page profile-page">
      <div className="profile-header">
        <div className="profile-avatar">👤</div>
        <h2>{displayProfile.name}</h2>
        <p className="nickname">@{displayProfile.nickname}</p>
        <p className="user-email">{displayProfile.email}</p>
        <div className="level-badge">Lv. {displayProfile.level}</div>
      </div>

      <div className="points-section">
        <div className="points-card">
          <span className="points-icon">⭐</span>
          <div>
            <div className="points-label">포인트</div>
            <div className="points-value">{displayProfile.points}P</div>
          </div>
        </div>
      </div>

      {displayProfile.badges.length > 0 && (
        <div className="badges-section">
          <h3>내 뱃지</h3>
          <div className="badges-grid">
            {displayProfile.badges.map((badge, index) => (
              <div key={index} className="badge-card">
                {badge}
              </div>
            ))}
          </div>
        </div>
      )}

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
        <button type="button" className="menu-item logout" onClick={handleLogout}>
          <span>🚪</span>
          <span>로그아웃</span>
          <span className="arrow">›</span>
        </button>
      </div>
    </div>
  )
}

export default Profile
