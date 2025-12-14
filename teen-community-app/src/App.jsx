import { BrowserRouter as Router, Routes, Route, useLocation, useNavigate } from 'react-router-dom'
import { MeetingProvider } from './context/MeetingContext'
import Home from './pages/Home'
import Explore from './pages/Explore'
import Recommend from './pages/Recommend'
import Meeting from './pages/Meeting'
import Community from './pages/Community'
import Profile from './pages/Profile'
import './App.css'

function Layout({ children }) {
  const location = useLocation()
  const navigate = useNavigate()

  const isActive = (path) => {
    if (path === '/') {
      return location.pathname === '/'
    }
    return location.pathname.startsWith(path)
  }

  return (
    <div className="app">
      <header className="header">
        <h1>🎉 청소년 커뮤니티</h1>
        <p className="subtitle">시험 끝났는데 뭐하지?</p>
      </header>

      <main className="main-content">
        {children}
      </main>

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
    </div>
  )
}

function App() {
  return (
    <Router>
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
          </Routes>
        </Layout>
      </MeetingProvider>
    </Router>
  )
}

export default App
