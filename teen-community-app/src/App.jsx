import { BrowserRouter as Router, Routes, Route, useLocation as useRouterLocation, useNavigate } from 'react-router-dom'
import { MeetingProvider } from './context/MeetingContext'
import { AuthProvider } from './context/AuthContext'
import { LocationProvider } from './context/LocationContext'
import { BookmarkProvider } from './context/BookmarkContext'
import Home from './pages/Home'
import Explore from './pages/Explore'
import Recommend from './pages/Recommend'
import Meeting from './pages/Meeting'
import Community from './pages/Community'
import Profile from './pages/Profile'
import Login from './pages/Login'
import SignUp from './pages/SignUp'
import PlaceDetail from './pages/PlaceDetail'
import WritePost from './pages/WritePost'
import PostDetail from './pages/PostDetail'
import BookmarkedPlaces from './pages/BookmarkedPlaces'
import Friends from './pages/Friends'
import Settings from './pages/Settings'
import './App.css'

function Layout({ children }) {
  const routerLocation = useRouterLocation()
  const navigate = useNavigate()

  // 특정 페이지에서는 하단 네비게이션 숨김
  const hideNavPaths = ['/login', '/signup', '/place', '/community/write', '/bookmarked', '/friends', '/settings']
  const hideNav = hideNavPaths.includes(routerLocation.pathname) ||
                  routerLocation.pathname.startsWith('/community/post/')

  const isActive = (path) => {
    if (path === '/') {
      return routerLocation.pathname === '/'
    }
    return routerLocation.pathname.startsWith(path)
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
      <LocationProvider>
        <AuthProvider>
          <BookmarkProvider>
            <MeetingProvider>
              <Layout>
                <Routes>
                  <Route path="/" element={<Home />} />
                  <Route path="/explore" element={<Explore />} />
                  <Route path="/recommend" element={<Recommend />} />
                  <Route path="/meeting" element={<Meeting />} />
                  <Route path="/meeting/create" element={<Meeting />} />
                  <Route path="/community" element={<Community />} />
                  <Route path="/community/write" element={<WritePost />} />
                  <Route path="/community/post/:postId" element={<PostDetail />} />
                  <Route path="/profile" element={<Profile />} />
                  <Route path="/bookmarked" element={<BookmarkedPlaces />} />
                  <Route path="/friends" element={<Friends />} />
                  <Route path="/settings" element={<Settings />} />
                  <Route path="/login" element={<Login />} />
                  <Route path="/signup" element={<SignUp />} />
                  <Route path="/place" element={<PlaceDetail />} />
                </Routes>
              </Layout>
            </MeetingProvider>
          </BookmarkProvider>
        </AuthProvider>
      </LocationProvider>
    </Router>
  )
}

export default App
