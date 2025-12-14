import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { getAllPlaces } from '../services/kakaoApi'
import { useLocation } from '../context/LocationContext'
import './Home.css'

function Home() {
  const navigate = useNavigate()
  const { longitude, latitude, address, loading: locationLoading, error: locationError, refreshLocation } = useLocation()
  const [popularPlaces, setPopularPlaces] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function loadPopularPlaces() {
      // 위치 로딩 중이면 대기
      if (locationLoading) return

      try {
        const places = await getAllPlaces({
          size: 3,
          x: longitude,
          y: latitude
        })
        // 상위 5개만 선택
        setPopularPlaces(places.slice(0, 5))
      } catch (error) {
        console.error('인기 장소 로드 실패:', error)
      } finally {
        setLoading(false)
      }
    }

    loadPopularPlaces()
  }, [longitude, latitude, locationLoading])

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
          <div className="category-card" onClick={() => navigate('/explore?category=karaoke')}>
            🎤 코인노래방
          </div>
          <div className="category-card" onClick={() => navigate('/explore?category=escape')}>
            🎯 방탈출
          </div>
          <div className="category-card" onClick={() => navigate('/explore?category=board')}>
            🎲 보드게임
          </div>
          <div className="category-card" onClick={() => navigate('/explore?category=movie')}>
            🎬 영화관
          </div>
          <div className="category-card" onClick={() => navigate('/explore?category=cafe')}>
            📚 북카페
          </div>
        </div>
      </div>

      <div className="popular-section">
        <div className="popular-header">
          <h3>📍 {address || '내 주변'} 인기 장소</h3>
          <button className="refresh-location-btn" onClick={refreshLocation} title="위치 새로고침">
            🔄
          </button>
        </div>
        {locationError && (
          <div className="location-error">
            ⚠️ {locationError}
          </div>
        )}
        {(loading || locationLoading) ? (
          <div className="loading-text">불러오는 중...</div>
        ) : (
          <div className="popular-list">
            {popularPlaces.map((place, index) => (
              <div
                key={place.id}
                className="popular-item"
                onClick={() => navigate(`/place?url=${encodeURIComponent(place.url)}&name=${encodeURIComponent(place.name)}`)}
              >
                <span className="rank">{index + 1}</span>
                <div className="place-thumbnail">
                  {place.thumbnail ? (
                    <img src={place.thumbnail} alt={place.name} />
                  ) : (
                    <span className="place-icon">{place.icon}</span>
                  )}
                </div>
                <div className="place-info">
                  <h4>{place.name}</h4>
                  <p>{place.location} | 🚶 {place.distance}</p>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}

export default Home
