import { useState } from 'react'
import { useSearchParams } from 'react-router-dom'
import './Explore.css'

function Explore() {
  const [searchParams] = useSearchParams()
  const category = searchParams.get('category')
  const [searchTerm, setSearchTerm] = useState('')

  const categories = [
    { id: 'all', icon: '🌟', name: '전체' },
    { id: 'movie', icon: '🎬', name: '영화관' },
    { id: 'escape', icon: '🎯', name: '방탈출' },
    { id: 'karaoke', icon: '🎤', name: '노래방' },
    { id: 'food', icon: '🍜', name: '먹거리' },
    { id: 'arcade', icon: '🎮', name: '오락실' },
    { id: 'cafe', icon: '📚', name: '북카페' },
  ]

  const [selectedCategory, setSelectedCategory] = useState(category || 'all')

  const places = [
    {
      id: 1,
      name: '미스터리 방탈출 카페',
      category: 'escape',
      location: '강남역',
      price: '15,000원~',
      rating: 4.8,
      reviews: 127,
      image: '🎯'
    },
    {
      id: 2,
      name: 'CGV 강남점',
      category: 'movie',
      location: '강남역',
      price: '8,000원~',
      rating: 4.6,
      reviews: 89,
      image: '🎬'
    },
    {
      id: 3,
      name: '엽기떡볶이',
      category: 'food',
      location: '홍대입구역',
      price: '5,000원~',
      rating: 4.5,
      reviews: 156,
      image: '🍜'
    },
    {
      id: 4,
      name: '코인노래방 24시',
      category: 'karaoke',
      location: '신촌역',
      price: '500원/곡',
      rating: 4.3,
      reviews: 92,
      image: '🎤'
    },
    {
      id: 5,
      name: '북카페 책과 쉼',
      category: 'cafe',
      location: '건대입구역',
      price: '4,000원~',
      rating: 4.7,
      reviews: 73,
      image: '📚'
    },
  ]

  const filteredPlaces = selectedCategory === 'all'
    ? places
    : places.filter(place => place.category === selectedCategory)

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
          📍 강남구
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

      <div className="places-list">
        {filteredPlaces.map(place => (
          <div key={place.id} className="place-card">
            <div className="place-image">{place.image}</div>
            <div className="place-details">
              <h3>{place.name}</h3>
              <p className="place-location">{place.location}</p>
              <p className="place-price">{place.price}</p>
              <div className="place-rating">
                <span>⭐ {place.rating}</span>
                <span className="review-count">({place.reviews})</span>
              </div>
            </div>
            <button className="bookmark-btn">🔖</button>
          </div>
        ))}
      </div>
    </div>
  )
}

export default Explore
