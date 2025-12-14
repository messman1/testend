import { useState, useEffect } from 'react'
import { useSearchParams } from 'react-router-dom'
import { searchByCategory, getAllPlaces } from '../services/kakaoApi'
import './Explore.css'

function Explore() {
  const [searchParams] = useSearchParams()
  const category = searchParams.get('category')
  const [searchTerm, setSearchTerm] = useState('')
  const [places, setPlaces] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  const categories = [
    { id: 'all', icon: '🌟', name: '전체' },
    { id: 'karaoke', icon: '🎤', name: '코인노래방' },
    { id: 'escape', icon: '🎯', name: '방탈출' },
    { id: 'board', icon: '🎲', name: '보드게임' },
    { id: 'movie', icon: '🎬', name: '영화관' },
    { id: 'cafe', icon: '📚', name: '북카페' },
  ]

  const [selectedCategory, setSelectedCategory] = useState(category || 'all')

  // 카테고리 변경 시 데이터 로드
  useEffect(() => {
    async function loadPlaces() {
      setLoading(true)
      setError(null)

      try {
        let data
        if (selectedCategory === 'all') {
          data = await getAllPlaces({ size: 5 })
        } else {
          data = await searchByCategory(selectedCategory, { size: 10 })
        }
        setPlaces(data)
      } catch (err) {
        setError('장소 정보를 불러오는데 실패했습니다.')
        console.error(err)
      } finally {
        setLoading(false)
      }
    }

    loadPlaces()
  }, [selectedCategory])

  // 검색어 필터링
  const filteredPlaces = searchTerm
    ? places.filter(place =>
        place.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        place.location.toLowerCase().includes(searchTerm.toLowerCase())
      )
    : places

  return (
    <div className="page explore-page">
      <div className="search-section">
        <div className="search-bar">
          <span className="search-icon">🔍</span>
          <input
            type="text"
            placeholder="장소, 음식, 활동 검색..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
        <div className="location-tag">
          📍 서초구
        </div>
      </div>

      <div className="category-tabs">
        {categories.map(cat => (
          <button
            key={cat.id}
            className={`category-tab ${selectedCategory === cat.id ? 'active' : ''}`}
            onClick={() => setSelectedCategory(cat.id)}
          >
            <span>{cat.icon}</span>
            <span>{cat.name}</span>
          </button>
        ))}
      </div>

      <div className="filter-section">
        <button className="filter-btn">💰 가격대</button>
        <button className="filter-btn">📏 거리순</button>
        <button className="filter-btn">⭐ 평점순</button>
      </div>

      {loading && (
        <div className="loading-state">
          <span>🔄</span>
          <p>장소 정보를 불러오는 중...</p>
        </div>
      )}

      {error && (
        <div className="error-state">
          <span>⚠️</span>
          <p>{error}</p>
        </div>
      )}

      {!loading && !error && (
        <div className="places-list">
          {filteredPlaces.length === 0 ? (
            <div className="empty-state">
              <span>🔍</span>
              <p>검색 결과가 없습니다.</p>
            </div>
          ) : (
            filteredPlaces.map(place => (
              <div
                key={place.id}
                className="place-card"
                onClick={() => window.open(place.url, '_blank')}
              >
                <div className="place-image">
                  {place.thumbnail ? (
                    <img
                      src={place.thumbnail}
                      alt={place.name}
                      onError={(e) => {
                        e.target.style.display = 'none';
                        e.target.nextSibling.style.display = 'flex';
                      }}
                    />
                  ) : null}
                  <span className="place-icon" style={{ display: place.thumbnail ? 'none' : 'flex' }}>
                    {place.icon}
                  </span>
                </div>
                <div className="place-details">
                  <h3>{place.name}</h3>
                  <p className="place-location">📍 {place.location}</p>
                  <p className="place-address">{place.address}</p>
                  {place.phone && <p className="place-phone">📞 {place.phone}</p>}
                  <div className="place-distance">
                    <span>🚶 {place.distance}</span>
                  </div>
                </div>
                <button className="bookmark-btn" onClick={(e) => {
                  e.stopPropagation()
                  // 북마크 기능 추가 예정
                }}>🔖</button>
              </div>
            ))
          )}
        </div>
      )}
    </div>
  )
}

export default Explore
