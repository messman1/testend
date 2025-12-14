import { useSearchParams, useNavigate } from 'react-router-dom'
import './PlaceDetail.css'

function PlaceDetail() {
  const [searchParams] = useSearchParams()
  const navigate = useNavigate()

  const url = searchParams.get('url')
  const name = searchParams.get('name') || '장소 상세'

  const handleBack = () => {
    navigate(-1)
  }

  const handleOpenExternal = () => {
    window.open(url, '_blank')
  }

  if (!url) {
    return (
      <div className="place-detail-page">
        <div className="place-detail-header">
          <button className="back-btn" onClick={handleBack}>
            ← 뒤로
          </button>
        </div>
        <div className="place-detail-error">
          <span>⚠️</span>
          <p>잘못된 접근입니다.</p>
          <button onClick={handleBack}>돌아가기</button>
        </div>
      </div>
    )
  }

  return (
    <div className="place-detail-page">
      <div className="place-detail-header">
        <button className="back-btn" onClick={handleBack}>
          ← 뒤로
        </button>
        <h2 className="place-title">{name}</h2>
        <button className="external-btn" onClick={handleOpenExternal} title="새 창에서 열기">
          ↗
        </button>
      </div>
      <div className="place-detail-content">
        <iframe
          src={url}
          title={name}
          className="place-iframe"
          allow="geolocation"
          sandbox="allow-scripts allow-same-origin allow-popups allow-forms"
        />
      </div>
    </div>
  )
}

export default PlaceDetail
