import { createContext, useContext, useState, useEffect } from 'react'

const BookmarkContext = createContext()

export function BookmarkProvider({ children }) {
  const [bookmarkedPlaces, setBookmarkedPlaces] = useState([])

  // localStorage에서 북마크 로드
  useEffect(() => {
    const saved = localStorage.getItem('bookmarkedPlaces')
    if (saved) {
      try {
        setBookmarkedPlaces(JSON.parse(saved))
      } catch (err) {
        console.error('북마크 로드 실패:', err)
      }
    }
  }, [])

  // localStorage에 북마크 저장
  const saveToStorage = (places) => {
    localStorage.setItem('bookmarkedPlaces', JSON.stringify(places))
  }

  // 장소 북마크 추가
  const addBookmark = (place) => {
    const newPlace = {
      id: place.id || place.name + Date.now(),
      name: place.name,
      address: place.address,
      location: place.location,
      url: place.url,
      phone: place.phone,
      category: place.category,
      icon: place.icon,
      thumbnail: place.thumbnail,
      bookmarkedAt: new Date().toISOString()
    }

    const updated = [...bookmarkedPlaces, newPlace]
    setBookmarkedPlaces(updated)
    saveToStorage(updated)
  }

  // 장소 북마크 제거
  const removeBookmark = (placeId) => {
    const updated = bookmarkedPlaces.filter(p => p.id !== placeId)
    setBookmarkedPlaces(updated)
    saveToStorage(updated)
  }

  // 북마크 여부 확인
  const isBookmarked = (placeId) => {
    return bookmarkedPlaces.some(p => p.id === placeId)
  }

  // 북마크 토글
  const toggleBookmark = (place) => {
    const placeId = place.id || place.name + Date.now()
    if (isBookmarked(placeId)) {
      removeBookmark(placeId)
      return false
    } else {
      addBookmark(place)
      return true
    }
  }

  return (
    <BookmarkContext.Provider value={{
      bookmarkedPlaces,
      addBookmark,
      removeBookmark,
      isBookmarked,
      toggleBookmark
    }}>
      {children}
    </BookmarkContext.Provider>
  )
}

export function useBookmarks() {
  const context = useContext(BookmarkContext)
  if (!context) {
    throw new Error('useBookmarks must be used within BookmarkProvider')
  }
  return context
}
