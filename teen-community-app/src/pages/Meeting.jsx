import { useState } from 'react'
import './Meeting.css'

function Meeting() {
  const [activeTab, setActiveTab] = useState('my')

  const myMeetings = [
    {
      id: 1,
      title: '시험 끝! 방탈출 가자',
      date: '2025-01-20',
      time: '14:00',
      place: '미스터리 방탈출 카페',
      participants: 4,
      maxParticipants: 6,
      status: 'upcoming'
    },
    {
      id: 2,
      title: '떡볶이 먹방 모임',
      date: '2025-01-22',
      time: '18:00',
      place: '엽기떡볶이',
      participants: 3,
      maxParticipants: 5,
      status: 'upcoming'
    }
  ]

  const invitedMeetings = [
    {
      id: 3,
      title: '노래방 가실 분~',
      date: '2025-01-21',
      time: '15:00',
      place: '코인노래방 24시',
      organizer: '민지',
      participants: 2,
      maxParticipants: 4,
      status: 'pending'
    }
  ]

  const pastMeetings = [
    {
      id: 4,
      title: '영화 보고 카페 가기',
      date: '2025-01-10',
      time: '13:00',
      place: 'CGV 강남점',
      participants: 5,
      status: 'completed'
    }
  ]

  const getMeetings = () => {
    switch(activeTab) {
      case 'my':
        return myMeetings
      case 'invited':
        return invitedMeetings
      case 'past':
        return pastMeetings
      default:
        return myMeetings
    }
  }

  return (
    <div className="page meeting-page">
      <div className="meeting-header">
        <h2>내 모임</h2>
        <button className="create-meeting-btn">➕ 모임 만들기</button>
      </div>

      <div className="meeting-tabs">
        <button
          className={`tab ${activeTab === 'my' ? 'active' : ''}`}
          onClick={() => setActiveTab('my')}
        >
          내 모임 ({myMeetings.length})
        </button>
        <button
          className={`tab ${activeTab === 'invited' ? 'active' : ''}`}
          onClick={() => setActiveTab('invited')}
        >
          초대받은 모임 ({invitedMeetings.length})
        </button>
        <button
          className={`tab ${activeTab === 'past' ? 'active' : ''}`}
          onClick={() => setActiveTab('past')}
        >
          지난 모임 ({pastMeetings.length})
        </button>
      </div>

      <div className="meetings-list">
        {getMeetings().map(meeting => (
          <div key={meeting.id} className="meeting-card">
            <div className="meeting-status-badge">
              {meeting.status === 'upcoming' && '예정'}
              {meeting.status === 'pending' && '초대'}
              {meeting.status === 'completed' && '완료'}
            </div>

            <h3>{meeting.title}</h3>

            <div className="meeting-info">
              <div className="info-row">
                <span className="icon">📅</span>
                <span>{meeting.date} {meeting.time}</span>
              </div>
              <div className="info-row">
                <span className="icon">📍</span>
                <span>{meeting.place}</span>
              </div>
              <div className="info-row">
                <span className="icon">👥</span>
                <span>
                  {meeting.participants}명 참여
                  {meeting.maxParticipants && ` / ${meeting.maxParticipants}명`}
                </span>
              </div>
              {meeting.organizer && (
                <div className="info-row">
                  <span className="icon">👤</span>
                  <span>{meeting.organizer}님의 모임</span>
                </div>
              )}
            </div>

            <div className="meeting-actions">
              {meeting.status === 'upcoming' && (
                <>
                  <button className="action-btn primary">💬 채팅</button>
                  <button className="action-btn">상세보기</button>
                </>
              )}
              {meeting.status === 'pending' && (
                <>
                  <button className="action-btn primary">✅ 수락</button>
                  <button className="action-btn">❌ 거절</button>
                </>
              )}
              {meeting.status === 'completed' && (
                <>
                  <button className="action-btn">후기 보기</button>
                  <button className="action-btn">사진 보기</button>
                </>
              )}
            </div>
          </div>
        ))}

        {getMeetings().length === 0 && (
          <div className="empty-state">
            <div className="empty-icon">📭</div>
            <p>아직 모임이 없어요</p>
            <button className="create-first-btn">첫 모임 만들기</button>
          </div>
        )}
      </div>
    </div>
  )
}

export default Meeting
