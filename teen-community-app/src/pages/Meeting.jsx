import { useState, useEffect } from 'react'
import { useLocation, useNavigate } from 'react-router-dom'
import { useMeetings } from '../context/MeetingContext'
import './Meeting.css'

function Meeting() {
  const location = useLocation()
  const navigate = useNavigate()
  const { meetings, createMeeting, deleteMeeting, getMyMeetings, getPastMeetings } = useMeetings()

  const [activeTab, setActiveTab] = useState('my')
  const [showCreateForm, setShowCreateForm] = useState(false)
  const [formData, setFormData] = useState({
    title: '',
    date: '',
    time: '',
    place: '',
    placeName: '',
    placeUrl: '',
    maxParticipants: 4,
    description: ''
  })

  // URL이 /meeting/create인 경우 또는 state로 장소 정보가 전달된 경우
  useEffect(() => {
    if (location.pathname === '/meeting/create') {
      setShowCreateForm(true)
    }

    // 추천 페이지에서 장소 정보가 전달된 경우
    if (location.state?.place) {
      const place = location.state.place
      setFormData(prev => ({
        ...prev,
        place: place.address || '',
        placeName: place.name || '',
        placeUrl: place.url || ''
      }))
      setShowCreateForm(true)
    }

    // 추천 코스에서 전달된 경우
    if (location.state?.course) {
      const course = location.state.course
      const placeNames = course.places.map(p => p.name).join(' → ')
      setFormData(prev => ({
        ...prev,
        title: course.title || '',
        placeName: placeNames,
        description: `코스: ${placeNames}`
      }))
      setShowCreateForm(true)
    }
  }, [location])

  const myMeetings = getMyMeetings()
  const pastMeetings = getPastMeetings()

  const handleInputChange = (e) => {
    const { name, value } = e.target
    setFormData(prev => ({ ...prev, [name]: value }))
  }

  const handleSubmit = (e) => {
    e.preventDefault()

    if (!formData.title || !formData.date || !formData.time) {
      alert('모임 이름, 날짜, 시간을 입력해주세요!')
      return
    }

    createMeeting({
      title: formData.title,
      date: formData.date,
      time: formData.time,
      place: formData.placeName || formData.place,
      placeUrl: formData.placeUrl,
      maxParticipants: parseInt(formData.maxParticipants),
      description: formData.description
    })

    // 폼 초기화
    setFormData({
      title: '',
      date: '',
      time: '',
      place: '',
      placeName: '',
      placeUrl: '',
      maxParticipants: 4,
      description: ''
    })

    setShowCreateForm(false)
    navigate('/meeting')
    alert('모임이 생성되었습니다! 🎉')
  }

  const handleDelete = (meetingId) => {
    if (window.confirm('정말 이 모임을 삭제하시겠습니까?')) {
      deleteMeeting(meetingId)
    }
  }

  const formatDate = (dateStr) => {
    const date = new Date(dateStr)
    const month = date.getMonth() + 1
    const day = date.getDate()
    const weekdays = ['일', '월', '화', '수', '목', '금', '토']
    const weekday = weekdays[date.getDay()]
    return `${month}월 ${day}일 (${weekday})`
  }

  // 오늘 날짜 (최소 선택 날짜)
  const today = new Date().toISOString().split('T')[0]

  return (
    <div className="page meeting-page">
      {!showCreateForm ? (
        <>
          <div className="meeting-header">
            <h2>내 모임</h2>
            <button
              className="create-meeting-btn"
              onClick={() => setShowCreateForm(true)}
            >
              ➕ 모임 만들기
            </button>
          </div>

          <div className="meeting-tabs">
            <button
              className={`tab ${activeTab === 'my' ? 'active' : ''}`}
              onClick={() => setActiveTab('my')}
            >
              예정된 모임 ({myMeetings.length})
            </button>
            <button
              className={`tab ${activeTab === 'past' ? 'active' : ''}`}
              onClick={() => setActiveTab('past')}
            >
              지난 모임 ({pastMeetings.length})
            </button>
          </div>

          <div className="meetings-list">
            {activeTab === 'my' && myMeetings.map(meeting => (
              <div key={meeting.id} className="meeting-card">
                <div className="meeting-status-badge upcoming">예정</div>

                <h3>{meeting.title}</h3>

                <div className="meeting-info">
                  <div className="info-row">
                    <span className="icon">📅</span>
                    <span>{formatDate(meeting.date)} {meeting.time}</span>
                  </div>
                  <div className="info-row">
                    <span className="icon">📍</span>
                    <span>{meeting.place}</span>
                  </div>
                  <div className="info-row">
                    <span className="icon">👥</span>
                    <span>
                      {meeting.participants}명 참여 / {meeting.maxParticipants}명
                    </span>
                  </div>
                  {meeting.description && (
                    <div className="info-row description">
                      <span>{meeting.description}</span>
                    </div>
                  )}
                </div>

                <div className="meeting-actions">
                  {meeting.placeUrl && (
                    <button
                      className="action-btn"
                      onClick={() => window.open(meeting.placeUrl, '_blank')}
                    >
                      📍 장소 보기
                    </button>
                  )}
                  <button
                    className="action-btn delete"
                    onClick={() => handleDelete(meeting.id)}
                  >
                    🗑️ 삭제
                  </button>
                </div>
              </div>
            ))}

            {activeTab === 'past' && pastMeetings.map(meeting => (
              <div key={meeting.id} className="meeting-card past">
                <div className="meeting-status-badge completed">완료</div>

                <h3>{meeting.title}</h3>

                <div className="meeting-info">
                  <div className="info-row">
                    <span className="icon">📅</span>
                    <span>{formatDate(meeting.date)} {meeting.time}</span>
                  </div>
                  <div className="info-row">
                    <span className="icon">📍</span>
                    <span>{meeting.place}</span>
                  </div>
                </div>
              </div>
            ))}

            {((activeTab === 'my' && myMeetings.length === 0) ||
              (activeTab === 'past' && pastMeetings.length === 0)) && (
              <div className="empty-state">
                <div className="empty-icon">📭</div>
                <p>{activeTab === 'my' ? '예정된 모임이 없어요' : '지난 모임이 없어요'}</p>
                {activeTab === 'my' && (
                  <button
                    className="create-first-btn"
                    onClick={() => setShowCreateForm(true)}
                  >
                    첫 모임 만들기
                  </button>
                )}
              </div>
            )}
          </div>
        </>
      ) : (
        <div className="create-form-container">
          <div className="form-header">
            <button className="back-btn" onClick={() => {
              setShowCreateForm(false)
              navigate('/meeting')
            }}>
              ← 뒤로
            </button>
            <h2>모임 만들기</h2>
          </div>

          <form onSubmit={handleSubmit} className="create-form">
            <div className="form-group">
              <label>모임 이름 *</label>
              <input
                type="text"
                name="title"
                value={formData.title}
                onChange={handleInputChange}
                placeholder="예: 시험 끝! 방탈출 가자"
                required
              />
            </div>

            <div className="form-row">
              <div className="form-group">
                <label>날짜 *</label>
                <input
                  type="date"
                  name="date"
                  value={formData.date}
                  onChange={handleInputChange}
                  min={today}
                  required
                />
              </div>
              <div className="form-group">
                <label>시간 *</label>
                <input
                  type="time"
                  name="time"
                  value={formData.time}
                  onChange={handleInputChange}
                  required
                />
              </div>
            </div>

            <div className="form-group">
              <label>장소</label>
              {formData.placeName ? (
                <div className="selected-place">
                  <span>📍 {formData.placeName}</span>
                  <button
                    type="button"
                    className="change-place-btn"
                    onClick={() => setFormData(prev => ({ ...prev, placeName: '', placeUrl: '' }))}
                  >
                    변경
                  </button>
                </div>
              ) : (
                <input
                  type="text"
                  name="place"
                  value={formData.place}
                  onChange={handleInputChange}
                  placeholder="장소를 입력하세요"
                />
              )}
              <button
                type="button"
                className="search-place-btn"
                onClick={() => navigate('/explore')}
              >
                🔍 장소 검색하기
              </button>
            </div>

            <div className="form-group">
              <label>최대 인원</label>
              <select
                name="maxParticipants"
                value={formData.maxParticipants}
                onChange={handleInputChange}
              >
                <option value="2">2명</option>
                <option value="3">3명</option>
                <option value="4">4명</option>
                <option value="5">5명</option>
                <option value="6">6명</option>
                <option value="8">8명</option>
                <option value="10">10명</option>
              </select>
            </div>

            <div className="form-group">
              <label>메모</label>
              <textarea
                name="description"
                value={formData.description}
                onChange={handleInputChange}
                placeholder="모임에 대한 추가 정보를 입력하세요"
                rows="3"
              />
            </div>

            <button type="submit" className="submit-btn">
              🎉 모임 만들기
            </button>
          </form>
        </div>
      )}
    </div>
  )
}

export default Meeting
