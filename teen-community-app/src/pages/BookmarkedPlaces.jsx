import { useNavigate } from 'react-router-dom'
import { useBookmarks } from '../context/BookmarkContext'
import './BookmarkedPlaces.css'

function BookmarkedPlaces() {
  const navigate = useNavigate()
  const { bookmarkedPlaces, removeBookmark } = useBookmarks()

  const handlePlaceClick = (place) => {
    navigate(`/place?url=${encodeURIComponent(place.url)}&name=${encodeURIComponent(place.name)}`)
  }

  const handleRemove = (e, placeId) => {
    e.stopPropagation()
    if (confirm('이 장소를 찜 목록에서 제거하시겠습니까?')) {
      removeBookmark(placeId)
    }
  }

  const formatDate = (dateString) => {
    const date = new Date(dateString)
    return date.toLocaleDateString('ko-KR', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    })
  }

  return (
    <div className="page bookmarked-places-page">
      <div className="page-header">
        <button className="back-btn" onClick={() => navigate('/profile')}>
          ← 뒤로
        </button>
        <h2>찜한 장소</h2>
      </div>

      {bookmarkedPlaces.length === 0 ? (
        <div className="empty-state">
          <div className="empty-icon">🔖</div>
          <p>찜한 장소가 없어요</p>
          <p className="empty-description">
            마음에 드는 장소를 찜해보세요!
          </p>
          <button
            className="go-explore-btn"
            onClick={() => navigate('/explore')}
          >
            장소 탐색하기
          </button>
        </div>
      ) : (
        <div className="bookmarked-list">
          {bookmarkedPlaces.map(place => (
            <div
              key={place.id}
              className="bookmarked-card"
              onClick={() => handlePlaceClick(place)}
            >
              <div className="place-image">
                {place.thumbnail ? (
                  <img
                    src={place.thumbnail}
                    alt={place.name}
                    onError={(e) => {
                      e.target.style.display = 'none'
                      e.target.nextSibling.style.display = 'flex'
                    }}
                  />
                ) : null}
                <span className="place-icon" style={{ display: place.thumbnail ? 'none' : 'flex' }}>
                  {place.icon || '📍'}
                </span>
              </div>
              <div className="place-details">
                <h3>{place.name}</h3>
                <p className="place-location">📍 {place.location}</p>
                <p className="place-address">{place.address}</p>
                {place.phone && <p className="place-phone">📞 {place.phone}</p>}
                <p className="bookmarked-date">
                  찜한 날짜: {formatDate(place.bookmarkedAt)}
                </p>
              </div>
              <button
                className="remove-btn"
                onClick={(e) => handleRemove(e, place.id)}
                title="찜 해제"
              >
                ❌
              </button>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}

export default BookmarkedPlaces
