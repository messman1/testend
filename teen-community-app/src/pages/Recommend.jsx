import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { searchByCategory, CATEGORY_ICONS } from '../services/kakaoApi'
import { useLocation } from '../context/LocationContext'
import './Recommend.css'

function Recommend() {
  const navigate = useNavigate()
  const { longitude, latitude, address } = useLocation()
  const [step, setStep] = useState(1)
  const [selections, setSelections] = useState({
    mood: null,
    people: null,
    time: null
  })
  const [loading, setLoading] = useState(false)
  const [recommendations, setRecommendations] = useState([])
  const [randomPlace, setRandomPlace] = useState(null)

  // 위치 옵션
  const locationOptions = { x: longitude, y: latitude }

  // 분위기별 추천 카테고리 매핑
  const moodCategories = {
    active: ['karaoke', 'escape'],      // 신나게 놀고 싶어
    chill: ['cafe', 'movie'],           // 조용히 쉬고 싶어
    social: ['board', 'escape'],        // 친구들이랑 어울리고 싶어
    adventure: ['escape', 'board']      // 새로운 거 해보고 싶어
  }

  // 코스 템플릿
  const courseTemplates = {
    short: {
      title: '짧게 즐기기',
      duration: '1-2시간',
      placeCount: 1
    },
    medium: {
      title: '알차게 놀기',
      duration: '3-4시간',
      placeCount: 2
    },
    long: {
      title: '하루종일 코스',
      duration: '5시간+',
      placeCount: 3
    }
  }

  const handleSelect = (category, value) => {
    setSelections(prev => ({ ...prev, [category]: value }))
    if (step < 3) {
      setStep(step + 1)
    } else {
      // 마지막 선택 후 추천 생성
      generateRecommendations({ ...selections, [category]: value })
    }
  }

  const generateRecommendations = async (finalSelections) => {
    setLoading(true)
    setStep(4)

    try {
      const categories = moodCategories[finalSelections.mood] || ['karaoke', 'escape']
      const template = courseTemplates[finalSelections.time] || courseTemplates.medium

      // 각 카테고리에서 장소 가져오기 (현재 위치 기준)
      const allPlaces = []
      for (const category of categories) {
        const places = await searchByCategory(category, { size: 5, ...locationOptions })
        allPlaces.push(...places.map(p => ({ ...p, categoryType: category })))
      }

      // 추천 코스 3개 생성
      const courses = []

      // 코스 1: 메인 활동 중심
      if (allPlaces.length > 0) {
        const mainPlaces = allPlaces.slice(0, template.placeCount)
        courses.push({
          id: 1,
          title: `${template.title} - ${getCategoryName(categories[0])} 코스`,
          icon: CATEGORY_ICONS[categories[0]],
          places: mainPlaces,
          duration: template.duration,
          description: getCoursDescription(finalSelections.mood, categories[0])
        })
      }

      // 코스 2: 믹스 코스
      if (allPlaces.length > 1) {
        const mixPlaces = []
        for (let i = 0; i < Math.min(template.placeCount, allPlaces.length); i++) {
          const idx = i * Math.floor(allPlaces.length / template.placeCount)
          if (allPlaces[idx]) mixPlaces.push(allPlaces[idx])
        }
        courses.push({
          id: 2,
          title: `${template.title} - 믹스 코스`,
          icon: '✨',
          places: mixPlaces,
          duration: template.duration,
          description: '다양한 활동을 즐길 수 있는 코스'
        })
      }

      // 코스 3: 서브 활동 중심
      if (categories[1] && allPlaces.length > 2) {
        const subPlaces = allPlaces
          .filter(p => p.categoryType === categories[1])
          .slice(0, template.placeCount)
        if (subPlaces.length > 0) {
          courses.push({
            id: 3,
            title: `${template.title} - ${getCategoryName(categories[1])} 코스`,
            icon: CATEGORY_ICONS[categories[1]],
            places: subPlaces,
            duration: template.duration,
            description: getCoursDescription(finalSelections.mood, categories[1])
          })
        }
      }

      setRecommendations(courses)
    } catch (error) {
      console.error('추천 생성 실패:', error)
    } finally {
      setLoading(false)
    }
  }

  const getCategoryName = (category) => {
    const names = {
      karaoke: '코인노래방',
      escape: '방탈출',
      board: '보드게임',
      movie: '영화관',
      cafe: '북카페'
    }
    return names[category] || category
  }

  const getCoursDescription = (mood, category) => {
    const descriptions = {
      active: {
        karaoke: '신나는 노래로 스트레스 해소!',
        escape: '두뇌 풀가동! 탈출에 도전해봐'
      },
      chill: {
        cafe: '조용한 공간에서 힐링 타임',
        movie: '편하게 영화 한 편 어때?'
      },
      social: {
        board: '친구들과 함께 보드게임 대결!',
        escape: '협동해서 방탈출 성공하기'
      },
      adventure: {
        escape: '새로운 테마에 도전해봐!',
        board: '처음 해보는 보드게임 어때?'
      }
    }
    return descriptions[mood]?.[category] || '재미있는 시간 보내세요!'
  }

  const handleRandomRecommend = async () => {
    setLoading(true)
    setRandomPlace(null)

    try {
      const categories = ['karaoke', 'escape', 'board', 'movie', 'cafe']
      const randomCategory = categories[Math.floor(Math.random() * categories.length)]
      const places = await searchByCategory(randomCategory, { size: 10, ...locationOptions })

      if (places.length > 0) {
        const randomIndex = Math.floor(Math.random() * places.length)
        setRandomPlace(places[randomIndex])
      }
    } catch (error) {
      console.error('랜덤 추천 실패:', error)
    } finally {
      setLoading(false)
    }
  }

  const resetQuiz = () => {
    setStep(1)
    setSelections({ mood: null, people: null, time: null })
    setRecommendations([])
    setRandomPlace(null)
  }

  return (
    <div className="page recommend-page">
      <div className="recommend-header">
        <h2>오늘 뭐하지? 🤔</h2>
        <p>몇 가지만 선택하면 딱 맞는 곳을 추천해줄게!</p>
      </div>

      {step <= 3 ? (
        <div className="quiz-section">
          <div className="progress-bar">
            <div className="progress-fill" style={{ width: `${(step / 3) * 100}%` }}></div>
          </div>

          {step === 1 && (
            <div className="question-card">
              <h3>🎯 오늘 기분이 어때?</h3>
              <div className="options-grid">
                <button className="option-btn" onClick={() => handleSelect('mood', 'active')}>
                  🎤 신나게 놀고 싶어!
                </button>
                <button className="option-btn" onClick={() => handleSelect('mood', 'chill')}>
                  😌 조용히 쉬고 싶어
                </button>
                <button className="option-btn" onClick={() => handleSelect('mood', 'social')}>
                  👥 친구들이랑 어울리고 싶어
                </button>
                <button className="option-btn" onClick={() => handleSelect('mood', 'adventure')}>
                  🌟 새로운 거 해보고 싶어!
                </button>
              </div>
            </div>
          )}

          {step === 2 && (
            <div className="question-card">
              <h3>👥 몇 명이서 놀아?</h3>
              <div className="options-grid">
                <button className="option-btn" onClick={() => handleSelect('people', '2')}>
                  👫 2명
                </button>
                <button className="option-btn" onClick={() => handleSelect('people', '3-4')}>
                  👨‍👩‍👧 3-4명
                </button>
                <button className="option-btn" onClick={() => handleSelect('people', '5+')}>
                  👨‍👩‍👧‍👦 5명 이상
                </button>
              </div>
            </div>
          )}

          {step === 3 && (
            <div className="question-card">
              <h3>⏰ 시간은 얼마나 있어?</h3>
              <div className="options-grid">
                <button className="option-btn" onClick={() => handleSelect('time', 'short')}>
                  ⚡ 1-2시간
                </button>
                <button className="option-btn" onClick={() => handleSelect('time', 'medium')}>
                  🕐 반나절 (3-4시간)
                </button>
                <button className="option-btn" onClick={() => handleSelect('time', 'long')}>
                  🌅 하루종일!
                </button>
              </div>
            </div>
          )}
        </div>
      ) : (
        <div className="results-section">
          <div className="results-header">
            <h3>✨ 추천 코스</h3>
            <button className="retry-btn" onClick={resetQuiz}>🔄 다시 선택</button>
          </div>

          {loading ? (
            <div className="loading-state">
              <span>🔄</span>
              <p>맞춤 추천을 준비하고 있어...</p>
            </div>
          ) : (
            <>
              <div className="courses-list">
                {recommendations.map(course => (
                  <div key={course.id} className="course-card">
                    <div className="course-header">
                      <div className="course-icon">{course.icon}</div>
                      <div className="course-title-area">
                        <h4>{course.title}</h4>
                        <p className="course-desc">{course.description}</p>
                      </div>
                    </div>

                    <div className="course-places">
                      {course.places.map((place, index) => (
                        <div
                          key={place.id}
                          className="course-place"
                          onClick={() => navigate(`/place?url=${encodeURIComponent(place.url)}&name=${encodeURIComponent(place.name)}`)}
                        >
                          <div className="place-number">{index + 1}</div>
                          <div className="place-thumb">
                            {place.thumbnail ? (
                              <img src={place.thumbnail} alt={place.name} />
                            ) : (
                              <span>{place.icon}</span>
                            )}
                          </div>
                          <div className="place-info">
                            <span className="place-name">{place.name}</span>
                            <span className="place-location">📍 {place.location} · {place.distance}</span>
                          </div>
                        </div>
                      ))}
                    </div>

                    <div className="course-footer">
                      <span className="course-duration">⏱️ {course.duration}</span>
                      <button
                        className="course-action-btn"
                        onClick={() => navigate('/meeting/create', {
                          state: { course: course }
                        })}
                      >
                        모임 만들기
                      </button>
                    </div>
                  </div>
                ))}
              </div>

              <div className="random-recommend">
                <h4>🎲 아직도 못 정하겠어?</h4>
                <button
                  className="random-btn"
                  onClick={handleRandomRecommend}
                  disabled={loading}
                >
                  {loading ? '뽑는 중...' : '랜덤으로 뽑아줘!'}
                </button>

                {randomPlace && (
                  <div
                    className="random-result"
                    onClick={() => navigate(`/place?url=${encodeURIComponent(randomPlace.url)}&name=${encodeURIComponent(randomPlace.name)}`)}
                  >
                    <div className="random-place-thumb">
                      {randomPlace.thumbnail ? (
                        <img src={randomPlace.thumbnail} alt={randomPlace.name} />
                      ) : (
                        <span>{randomPlace.icon}</span>
                      )}
                    </div>
                    <div className="random-place-info">
                      <h5>{randomPlace.name}</h5>
                      <p>📍 {randomPlace.location} · {randomPlace.distance}</p>
                    </div>
                    <span className="random-arrow">→</span>
                  </div>
                )}
              </div>
            </>
          )}
        </div>
      )}
    </div>
  )
}

export default Recommend
