import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import './Settings.css'

function Settings() {
  const navigate = useNavigate()
  const { user, profile } = useAuth()

  // 설정 상태 (localStorage에 저장)
  const [settings, setSettings] = useState({
    notifications: {
      push: localStorage.getItem('setting_push') !== 'false',
      email: localStorage.getItem('setting_email') !== 'false',
      meeting: localStorage.getItem('setting_meeting') !== 'false',
      community: localStorage.getItem('setting_community') !== 'false'
    },
    privacy: {
      showProfile: localStorage.getItem('setting_showProfile') !== 'false',
      showActivity: localStorage.getItem('setting_showActivity') !== 'false'
    },
    theme: localStorage.getItem('setting_theme') || 'light'
  })

  const handleToggle = (category, key) => {
    const newValue = !settings[category][key]
    setSettings({
      ...settings,
      [category]: {
        ...settings[category],
        [key]: newValue
      }
    })
    localStorage.setItem(`setting_${key}`, newValue)
  }

  const handleThemeChange = (theme) => {
    setSettings({ ...settings, theme })
    localStorage.setItem('setting_theme', theme)
  }

  const handleDeleteAccount = () => {
    if (confirm('정말로 계정을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.')) {
      const confirmText = prompt('계정 삭제를 확인하려면 "삭제"를 입력하세요:')
      if (confirmText === '삭제') {
        alert('계정 삭제 기능은 준비 중입니다.')
        // TODO: 계정 삭제 로직 구현
      }
    }
  }

  const handleClearCache = () => {
    if (confirm('캐시를 삭제하시겠습니까?')) {
      // localStorage에서 캐시 데이터만 삭제
      const keysToKeep = ['bookmarkedPlaces', 'meetings', 'setting_']
      const allKeys = Object.keys(localStorage)

      allKeys.forEach(key => {
        const shouldKeep = keysToKeep.some(keepKey => key.startsWith(keepKey))
        if (!shouldKeep && !key.includes('supabase')) {
          localStorage.removeItem(key)
        }
      })

      alert('캐시가 삭제되었습니다.')
    }
  }

  return (
    <div className="page settings-page">
      <div className="page-header">
        <button className="back-btn" onClick={() => navigate('/profile')}>
          ← 뒤로
        </button>
        <h2>설정</h2>
      </div>

      <div className="settings-content">
        {/* 계정 정보 */}
        <section className="settings-section">
          <h3 className="section-title">계정 정보</h3>
          <div className="settings-group">
            <div className="info-item">
              <span className="info-label">이메일</span>
              <span className="info-value">{user?.email}</span>
            </div>
            <div className="info-item">
              <span className="info-label">닉네임</span>
              <span className="info-value">{profile?.nickname || '미설정'}</span>
            </div>
            <div className="info-item">
              <span className="info-label">레벨</span>
              <span className="info-value">Lv.{profile?.level || 1}</span>
            </div>
          </div>
        </section>

        {/* 알림 설정 */}
        <section className="settings-section">
          <h3 className="section-title">알림 설정</h3>
          <div className="settings-group">
            <div className="setting-item">
              <div className="setting-info">
                <span className="setting-label">푸시 알림</span>
                <span className="setting-desc">앱 알림 받기</span>
              </div>
              <label className="toggle-switch">
                <input
                  type="checkbox"
                  checked={settings.notifications.push}
                  onChange={() => handleToggle('notifications', 'push')}
                />
                <span className="toggle-slider"></span>
              </label>
            </div>

            <div className="setting-item">
              <div className="setting-info">
                <span className="setting-label">이메일 알림</span>
                <span className="setting-desc">이메일로 소식 받기</span>
              </div>
              <label className="toggle-switch">
                <input
                  type="checkbox"
                  checked={settings.notifications.email}
                  onChange={() => handleToggle('notifications', 'email')}
                />
                <span className="toggle-slider"></span>
              </label>
            </div>

            <div className="setting-item">
              <div className="setting-info">
                <span className="setting-label">모임 알림</span>
                <span className="setting-desc">모임 관련 알림</span>
              </div>
              <label className="toggle-switch">
                <input
                  type="checkbox"
                  checked={settings.notifications.meeting}
                  onChange={() => handleToggle('notifications', 'meeting')}
                />
                <span className="toggle-slider"></span>
              </label>
            </div>

            <div className="setting-item">
              <div className="setting-info">
                <span className="setting-label">커뮤니티 알림</span>
                <span className="setting-desc">댓글, 좋아요 알림</span>
              </div>
              <label className="toggle-switch">
                <input
                  type="checkbox"
                  checked={settings.notifications.community}
                  onChange={() => handleToggle('notifications', 'community')}
                />
                <span className="toggle-slider"></span>
              </label>
            </div>
          </div>
        </section>

        {/* 프라이버시 설정 */}
        <section className="settings-section">
          <h3 className="section-title">프라이버시</h3>
          <div className="settings-group">
            <div className="setting-item">
              <div className="setting-info">
                <span className="setting-label">프로필 공개</span>
                <span className="setting-desc">다른 사용자에게 프로필 공개</span>
              </div>
              <label className="toggle-switch">
                <input
                  type="checkbox"
                  checked={settings.privacy.showProfile}
                  onChange={() => handleToggle('privacy', 'showProfile')}
                />
                <span className="toggle-slider"></span>
              </label>
            </div>

            <div className="setting-item">
              <div className="setting-info">
                <span className="setting-label">활동 공개</span>
                <span className="setting-desc">활동 내역 공개</span>
              </div>
              <label className="toggle-switch">
                <input
                  type="checkbox"
                  checked={settings.privacy.showActivity}
                  onChange={() => handleToggle('privacy', 'showActivity')}
                />
                <span className="toggle-slider"></span>
              </label>
            </div>
          </div>
        </section>

        {/* 테마 설정 */}
        <section className="settings-section">
          <h3 className="section-title">테마</h3>
          <div className="settings-group">
            <div className="theme-options">
              <button
                className={`theme-btn ${settings.theme === 'light' ? 'active' : ''}`}
                onClick={() => handleThemeChange('light')}
              >
                ☀️ 라이트 모드
              </button>
              <button
                className={`theme-btn ${settings.theme === 'dark' ? 'active' : ''}`}
                onClick={() => handleThemeChange('dark')}
                disabled
              >
                🌙 다크 모드 (준비중)
              </button>
            </div>
          </div>
        </section>

        {/* 앱 정보 */}
        <section className="settings-section">
          <h3 className="section-title">앱 정보</h3>
          <div className="settings-group">
            <button className="info-btn" onClick={() => alert('버전: 1.0.0')}>
              <span>📱</span>
              <span>버전 정보</span>
              <span className="arrow">›</span>
            </button>
            <button className="info-btn" onClick={() => alert('이용약관 페이지는 준비중입니다.')}>
              <span>📄</span>
              <span>이용약관</span>
              <span className="arrow">›</span>
            </button>
            <button className="info-btn" onClick={() => alert('개인정보처리방침 페이지는 준비중입니다.')}>
              <span>🔒</span>
              <span>개인정보처리방침</span>
              <span className="arrow">›</span>
            </button>
            <button className="info-btn" onClick={handleClearCache}>
              <span>🗑️</span>
              <span>캐시 삭제</span>
              <span className="arrow">›</span>
            </button>
          </div>
        </section>

        {/* 위험 영역 */}
        <section className="settings-section danger-zone">
          <h3 className="section-title">위험 영역</h3>
          <div className="settings-group">
            <button className="danger-btn" onClick={handleDeleteAccount}>
              <span>⚠️</span>
              <span>계정 삭제</span>
              <span className="arrow">›</span>
            </button>
          </div>
        </section>
      </div>
    </div>
  )
}

export default Settings
