import { useState } from 'react'
import './Recommend.css'

function Recommend() {
  const [step, setStep] = useState(1)
  const [selections, setSelections] = useState({
    people: null,
    budget: null,
    activity: null,
    duration: null
  })

  const handleSelect = (category, value) => {
    setSelections(prev => ({ ...prev, [category]: value }))
    if (step < 4) {
      setStep(step + 1)
    }
  }

  const resetQuiz = () => {
    setStep(1)
    setSelections({
      people: null,
      budget: null,
      activity: null,
      duration: null
    })
  }

  const recommendedCourses = [
    {
      id: 1,
      title: '완벽한 3시간 코스',
      places: ['방탈출 카페', '떡볶이', '코인노래방'],
      cost: '13,000원',
      duration: '3시간',
      icon: '🎯'
    },
    {
      id: 2,
      title: '맛집 투어',
      places: ['마라탕', '디저트 카페', '공원 산책'],
      cost: '15,000원',
      duration: '3시간',
      icon: '🍜'
    },
    {
      id: 3,
      title: '힐링 코스',
      places: ['북카페', '보드게임방'],
      cost: '10,000원',
      duration: '3시간',
      icon: '📚'
    }
  ]

  return (
    <div className="page recommend-page">
      <div className="recommend-header">
        <h2>시험 끝났는데 뭐하지?</h2>
        <p>몇 가지만 선택하면 딱 맞는 코스를 추천해줄게!</p>
      </div>

      {step <= 4 ? (
        <div className="quiz-section">
          <div className="progress-bar">
            <div className="progress-fill" style={{ width: `${(step / 4) * 100}%` }}></div>
          </div>

          {step === 1 && (
            <div className="question-card">
              <h3>👥 우리 몇 명이야?</h3>
              <div className="options-grid">
                <button className="option-btn" onClick={() => handleSelect('people', '2')}>
                  2명
                </button>
                <button className="option-btn" onClick={() => handleSelect('people', '3-5')}>
                  3-5명
                </button>
                <button className="option-btn" onClick={() => handleSelect('people', '6+')}>
                  6명 이상
                </button>
              </div>
            </div>
          )}

          {step === 2 && (
            <div className="question-card">
              <h3>💰 예산은 얼마야?</h3>
              <div className="options-grid">
                <button className="option-btn" onClick={() => handleSelect('budget', '10000')}>
                  1만원 이하
                </button>
                <button className="option-btn" onClick={() => handleSelect('budget', '20000')}>
                  1~2만원
                </button>
                <button className="option-btn" onClick={() => handleSelect('budget', '20000+')}>
                  2만원 이상
                </button>
              </div>
            </div>
          )}

          {step === 3 && (
            <div className="question-card">
              <h3>🎯 뭐 하고 싶어?</h3>
              <div className="options-grid">
                <button className="option-btn" onClick={() => handleSelect('activity', 'eat')}>
                  🍜 먹기
                </button>
                <button className="option-btn" onClick={() => handleSelect('activity', 'play')}>
                  🎮 놀기
                </button>
                <button className="option-btn" onClick={() => handleSelect('activity', 'relax')}>
                  😌 쉬기
                </button>
                <button className="option-btn" onClick={() => handleSelect('activity', 'active')}>
                  🏃 활동적인 거
                </button>
              </div>
            </div>
          )}

          {step === 4 && (
            <div className="question-card">
              <h3>⏱️ 시간은 얼마나 있어?</h3>
              <div className="options-grid">
                <button className="option-btn" onClick={() => handleSelect('duration', '1-2')}>
                  1-2시간
                </button>
                <button className="option-btn" onClick={() => handleSelect('duration', '3-4')}>
                  반나절 (3-4시간)
                </button>
                <button className="option-btn" onClick={() => handleSelect('duration', 'full')}>
                  하루종일
                </button>
              </div>
            </div>
          )}
        </div>
      ) : (
        <div className="results-section">
          <div className="results-header">
            <h3>✨ 너희에게 딱 맞는 코스!</h3>
            <button className="retry-btn" onClick={resetQuiz}>🔄 다시 선택하기</button>
          </div>

          <div className="courses-list">
            {recommendedCourses.map(course => (
              <div key={course.id} className="course-card">
                <div className="course-icon">{course.icon}</div>
                <div className="course-info">
                  <h4>{course.title}</h4>
                  <div className="course-route">
                    {course.places.map((place, index) => (
                      <span key={index}>
                        {place}
                        {index < course.places.length - 1 && ' → '}
                      </span>
                    ))}
                  </div>
                  <div className="course-meta">
                    <span>💰 1인 {course.cost}</span>
                    <span>⏱️ {course.duration}</span>
                  </div>
                </div>
                <button className="course-action-btn">모임 만들기</button>
              </div>
            ))}
          </div>

          <div className="random-recommend">
            <h4>🎲 아직도 못 정하겠어?</h4>
            <button className="random-btn">랜덤으로 뽑아줘!</button>
          </div>
        </div>
      )}
    </div>
  )
}

export default Recommend
