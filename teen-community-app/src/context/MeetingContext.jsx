import { createContext, useContext, useState, useEffect } from 'react'

const MeetingContext = createContext()

// localStorage 키
const STORAGE_KEY = 'teen-community-meetings'

// 초기 데이터 (예시)
const initialMeetings = []

export function MeetingProvider({ children }) {
  const [meetings, setMeetings] = useState(() => {
    // localStorage에서 데이터 로드
    const saved = localStorage.getItem(STORAGE_KEY)
    return saved ? JSON.parse(saved) : initialMeetings
  })

  // meetings 변경 시 localStorage에 저장
  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(meetings))
  }, [meetings])

  // 모임 생성
  const createMeeting = (meetingData) => {
    const newMeeting = {
      id: Date.now(),
      ...meetingData,
      participants: 1,
      status: 'upcoming',
      createdAt: new Date().toISOString()
    }
    setMeetings(prev => [newMeeting, ...prev])
    return newMeeting
  }

  // 모임 삭제
  const deleteMeeting = (meetingId) => {
    setMeetings(prev => prev.filter(m => m.id !== meetingId))
  }

  // 모임 수정
  const updateMeeting = (meetingId, updates) => {
    setMeetings(prev => prev.map(m =>
      m.id === meetingId ? { ...m, ...updates } : m
    ))
  }

  // 내 모임 (예정된 모임)
  const getMyMeetings = () => {
    return meetings.filter(m => m.status === 'upcoming')
  }

  // 지난 모임
  const getPastMeetings = () => {
    return meetings.filter(m => m.status === 'completed')
  }

  // 모임 완료 처리
  const completeMeeting = (meetingId) => {
    updateMeeting(meetingId, { status: 'completed' })
  }

  const value = {
    meetings,
    createMeeting,
    deleteMeeting,
    updateMeeting,
    getMyMeetings,
    getPastMeetings,
    completeMeeting
  }

  return (
    <MeetingContext.Provider value={value}>
      {children}
    </MeetingContext.Provider>
  )
}

export function useMeetings() {
  const context = useContext(MeetingContext)
  if (!context) {
    throw new Error('useMeetings must be used within a MeetingProvider')
  }
  return context
}

export default MeetingContext
