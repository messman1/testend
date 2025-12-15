import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import {
  getMyFriends,
  getReceivedFriendRequests,
  sendFriendRequest,
  acceptFriendRequest,
  rejectFriendRequest,
  removeFriend
} from '../services/friendsApi'
import './Friends.css'

function Friends() {
  const navigate = useNavigate()
  const { user } = useAuth()
  const [activeTab, setActiveTab] = useState('all')
  const [searchTerm, setSearchTerm] = useState('')
  const [friends, setFriends] = useState([])
  const [requests, setRequests] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  // 데이터 로드
  useEffect(() => {
    if (user) {
      loadData()
    }
  }, [user])

  const loadData = async () => {
    try {
      setLoading(true)
      setError(null)
      const [friendsData, requestsData] = await Promise.all([
        getMyFriends(user.id),
        getReceivedFriendRequests(user.id)
      ])
      setFriends(friendsData)
      setRequests(requestsData)
    } catch (err) {
      console.error('데이터 로드 실패:', err)
      setError('데이터를 불러오는데 실패했습니다.')
    } finally {
      setLoading(false)
    }
  }

  const filteredFriends = searchTerm
    ? friends.filter(f =>
        f.nickname.toLowerCase().includes(searchTerm.toLowerCase()) ||
        f.email.toLowerCase().includes(searchTerm.toLowerCase())
      )
    : friends

  const handleAcceptRequest = async (requestId) => {
    try {
      await acceptFriendRequest(requestId, user.id)
      alert('친구 요청을 수락했습니다!')
      await loadData() // 데이터 새로고침
    } catch (err) {
      console.error('친구 요청 수락 실패:', err)
      alert('친구 요청 수락에 실패했습니다. 다시 시도해주세요.')
    }
  }

  const handleRejectRequest = async (requestId) => {
    if (confirm('친구 요청을 거절하시겠습니까?')) {
      try {
        await rejectFriendRequest(requestId, user.id)
        alert('친구 요청을 거절했습니다.')
        await loadData() // 데이터 새로고침
      } catch (err) {
        console.error('친구 요청 거절 실패:', err)
        alert('친구 요청 거절에 실패했습니다. 다시 시도해주세요.')
      }
    }
  }

  const handleRemoveFriend = async (friendId) => {
    if (confirm('친구를 삭제하시겠습니까?')) {
      try {
        await removeFriend(user.id, friendId)
        alert('친구가 삭제되었습니다.')
        await loadData() // 데이터 새로고침
      } catch (err) {
        console.error('친구 삭제 실패:', err)
        alert('친구 삭제에 실패했습니다. 다시 시도해주세요.')
      }
    }
  }

  const handleAddFriend = async () => {
    const friendEmail = prompt('친구의 이메일을 입력하세요:')
    if (friendEmail) {
      try {
        await sendFriendRequest(user.id, friendEmail.trim())
        alert('친구 요청을 보냈습니다!')
      } catch (err) {
        console.error('친구 요청 보내기 실패:', err)
        alert(err.message || '친구 요청 보내기에 실패했습니다.')
      }
    }
  }

  const formatLastSeen = (date) => {
    const now = new Date()
    const diff = now - date
    const minutes = Math.floor(diff / 60000)
    const hours = Math.floor(diff / 3600000)
    const days = Math.floor(diff / 86400000)

    if (minutes < 1) return '방금 전'
    if (minutes < 60) return `${minutes}분 전`
    if (hours < 24) return `${hours}시간 전`
    return `${days}일 전`
  }

  if (!user) {
    return (
      <div className="page friends-page">
        <div className="empty-state">
          <div className="empty-icon">🔒</div>
          <p>로그인이 필요합니다</p>
          <button className="add-first-btn" onClick={() => navigate('/login')}>
            로그인하기
          </button>
        </div>
      </div>
    )
  }

  return (
    <div className="page friends-page">
      <div className="page-header">
        <button className="back-btn" onClick={() => navigate('/profile')}>
          ← 뒤로
        </button>
        <h2>친구 관리</h2>
        <button className="add-friend-btn" onClick={handleAddFriend}>
          ➕
        </button>
      </div>

      {error && (
        <div className="error-banner">
          {error}
        </div>
      )}

      <div className="search-section">
        <input
          type="text"
          className="friend-search"
          placeholder="친구 검색..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
        />
      </div>

      <div className="friends-tabs">
        <button
          className={`tab ${activeTab === 'all' ? 'active' : ''}`}
          onClick={() => setActiveTab('all')}
        >
          전체 친구 ({friends.length})
        </button>
        <button
          className={`tab ${activeTab === 'requests' ? 'active' : ''}`}
          onClick={() => setActiveTab('requests')}
        >
          친구 요청 ({requests.length})
        </button>
      </div>

      {loading && (
        <div className="loading-state">
          <p>로딩 중...</p>
        </div>
      )}

      {!loading && activeTab === 'all' && (
        <div className="friends-list">
          {filteredFriends.length === 0 ? (
            <div className="empty-state">
              <div className="empty-icon">👥</div>
              <p>친구가 없어요</p>
              <p className="empty-description">
                친구를 추가하고 함께 즐거운 시간을 보내세요!
              </p>
              <button className="add-first-btn" onClick={handleAddFriend}>
                첫 친구 추가하기
              </button>
            </div>
          ) : (
            filteredFriends.map(friend => (
              <div key={friend.id} className="friend-card">
                <div className="friend-avatar">
                  <span>👤</span>
                </div>
                <div className="friend-info">
                  <div className="friend-name">
                    {friend.nickname}
                    <span className="friend-level">Lv.{friend.level}</span>
                  </div>
                  <div className="friend-email">{friend.email}</div>
                  <div className="friend-status">
                    {formatLastSeen(new Date(friend.created_at))} 친구
                  </div>
                </div>
                <div className="friend-actions">
                  <button
                    className="action-btn message"
                    onClick={() => alert('메시지 기능은 준비중입니다')}
                  >
                    💬
                  </button>
                  <button
                    className="action-btn remove"
                    onClick={() => handleRemoveFriend(friend.id)}
                  >
                    🗑️
                  </button>
                </div>
              </div>
            ))
          )}
        </div>
      )}

      {!loading && activeTab === 'requests' && (
        <div className="requests-list">
          {requests.length === 0 ? (
            <div className="empty-state">
              <div className="empty-icon">📬</div>
              <p>친구 요청이 없어요</p>
            </div>
          ) : (
            requests.map(request => (
              <div key={request.id} className="request-card">
                <div className="friend-avatar">
                  <span>👤</span>
                </div>
                <div className="friend-info">
                  <div className="friend-name">
                    {request.nickname}
                    <span className="friend-level">Lv.{request.level}</span>
                  </div>
                  <div className="friend-email">{request.email}</div>
                  <div className="request-time">
                    {formatLastSeen(new Date(request.created_at))} 요청
                  </div>
                </div>
                <div className="request-actions">
                  <button
                    className="accept-btn"
                    onClick={() => handleAcceptRequest(request.id)}
                  >
                    수락
                  </button>
                  <button
                    className="reject-btn"
                    onClick={() => handleRejectRequest(request.id)}
                  >
                    거절
                  </button>
                </div>
              </div>
            ))
          )}
        </div>
      )}

      <div className="my-friend-code">
        <h3>내 친구 코드</h3>
        <div className="friend-code-box">
          <span className="code">{user?.email || '로그인 필요'}</span>
          <button
            className="copy-btn"
            onClick={() => {
              navigator.clipboard.writeText(user?.email || '')
              alert('친구 코드가 복사되었습니다!')
            }}
          >
            📋 복사
          </button>
        </div>
        <p className="code-description">
          친구에게 이 코드를 공유하여 친구 요청을 받을 수 있습니다.
        </p>
      </div>
    </div>
  )
}

export default Friends
