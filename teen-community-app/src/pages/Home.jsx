import { useNavigate } from 'react-router-dom'
import './Home.css'

function Home() {
  const navigate = useNavigate()

  return (
    <div className="page">
      <div className="welcome-section">
        <h2>환영합니다!</h2>
        <p>친구들과 함께 즐거운 시간을 보낼 장소를 찾아보세요</p>
      </div>

      <div className="quick-actions">
        <button className="action-btn primary" onClick={() => navigate('/recommend')}>
          <span className="icon">🎯</span>
          <span>오늘 뭐하지?</span>
        </button>
        <button className="action-btn" onClick={() => navigate('/explore')}>
          <span className="icon">📍</span>
          <span>주변 장소 찾기</span>
        </button>
        <button className="action-btn" onClick={() => navigate('/meeting/create')}>
          <span className="icon">👥</span>
          <span>모임 만들기</span>
        </button>
      </div>

      <div className="categories">
        <h3>인기 카테고리</h3>
        <div className="category-grid">
          <div className="category-card" onClick={() => navigate('/explore?category=movie')}>
            🎬 영화관
          </div>
          <div className="category-card" onClick={() => navigate('/explore?category=escape')}>
            🎯 방탈출
          </div>
          <div className="category-card" onClick={() => navigate('/explore?category=karaoke')}>
            🎤 노래방
          </div>
          <div className="category-card" onClick={() => navigate('/explore?category=food')}>
            🍜 먹거리
          </div>
          <div className="category-card" onClick={() => navigate('/explore?category=arcade')}>
            🎮 오락실
          </div>
          <div className="category-card" onClick={() => navigate('/explore?category=cafe')}>
            📚 북카페
          </div>
        </div>
      </div>

      <div className="popular-section">
        <h3>이번 주 인기 장소 TOP 5</h3>
        <div className="popular-list">
          <div className="popular-item">
            <span className="rank">1</span>
            <div className="place-info">
              <h4>🎯 미스터리 방탈출 카페</h4>
              <p>강남역 | ⭐ 4.8 (127명)</p>
            </div>
          </div>
          <div className="popular-item">
            <span className="rank">2</span>
            <div className="place-info">
              <h4>🎬 CGV 강남점</h4>
              <p>강남역 | ⭐ 4.6 (89명)</p>
            </div>
          </div>
          <div className="popular-item">
            <span className="rank">3</span>
            <div className="place-info">
              <h4>🍜 엽기떡볶이</h4>
              <p>홍대입구역 | ⭐ 4.5 (156명)</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default Home
