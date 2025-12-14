import { BrowserRouter as Router, Routes, Route, useLocation, useNavigate } from 'react-router-dom'
import { MeetingProvider } from './context/MeetingContext'
import { AuthProvider } from './context/AuthContext'
import Home from './pages/Home'
import Explore from './pages/Explore'
import Recommend from './pages/Recommend'
import Meeting from './pages/Meeting'
import Community from './pages/Community'
import Profile from './pages/Profile'
import Login from './pages/Login'
import SignUp from './pages/SignUp'
import './App.css'

function Layout({ children }) {
  const location = useLocation()
  const navigate = useNavigate()

  // 인증 페이지에서는 하단 네비게이션 숨김
  const hideNav = ['/login', '/signup'].includes(location.pathname)

  const isActive = (path) => {
    if (path === '/') {
      return location.pathname === '/'
    }
    return location.pathname.startsWith(path)
  }

  return (
    <div className="app">
      <header className="header">
        <h1>🐶 시험끝 오늘은 놀자!</h1>
      </header>

      <main className="main-content">
        {children}
      </main>

      {!hideNav && (
      <nav className="bottom-nav">
        <button
          className={`nav-item ${isActive('/') ? 'active' : ''}`}
          onClick={() => navigate('/')}
        >
          <span>🏠</span>
          <span>홈</span>
        </button>
        <button
          className={`nav-item ${isActive('/explore') ? 'active' : ''}`}
          onClick={() => navigate('/explore')}
        >
          <span>🔍</span>
          <span>탐색</span>
        </button>
        <button
          className={`nav-item ${isActive('/meeting') ? 'active' : ''}`}
          onClick={() => navigate('/meeting')}
        >
          <span>➕</span>
          <span>모임</span>
        </button>
        <button
          className={`nav-item ${isActive('/community') ? 'active' : ''}`}
          onClick={() => navigate('/community')}
        >
          <span>💬</span>
          <span>소식</span>
        </button>
        <button
          className={`nav-item ${isActive('/profile') ? 'active' : ''}`}
          onClick={() => navigate('/profile')}
        >
          <span>👤</span>
          <span>MY</span>
        </button>
      </nav>
      )}
    </div>
  )
}

function App() {
  return (
    <Router>
      <AuthProvider>
        <MeetingProvider>
          <Layout>
            <Routes>
              <Route path="/" element={<Home />} />
              <Route path="/explore" element={<Explore />} />
              <Route path="/recommend" element={<Recommend />} />
              <Route path="/meeting" element={<Meeting />} />
              <Route path="/meeting/create" element={<Meeting />} />
              <Route path="/community" element={<Community />} />
              <Route path="/profile" element={<Profile />} />
              <Route path="/login" element={<Login />} />
              <Route path="/signup" element={<SignUp />} />
            </Routes>
          </Layout>
        </MeetingProvider>
      </AuthProvider>
    </Router>
  )
}

export default App
