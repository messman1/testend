import { createContext, useContext, useState, useEffect, useCallback } from 'react'

const LocationContext = createContext()

// 기본 위치 (서울 시청 - GPS 실패시 사용)
const DEFAULT_LOCATION = {
  latitude: 37.5666805,
  longitude: 126.9784147,
  address: '서울시청'
}

export function LocationProvider({ children }) {
  const [location, setLocation] = useState(null)
  const [address, setAddress] = useState('')
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [permissionDenied, setPermissionDenied] = useState(false)

  // 좌표를 주소로 변환 (카카오 API 사용)
  const getAddressFromCoords = async (latitude, longitude) => {
    const KAKAO_API_KEY = '6c3d9e2d50c653818b7fbee8dcd1b9f5'

    try {
      const response = await fetch(
        `https://dapi.kakao.com/v2/local/geo/coord2regioncode.json?x=${longitude}&y=${latitude}`,
        {
          headers: {
            'Authorization': `KakaoAK ${KAKAO_API_KEY}`
          }
        }
      )

      if (!response.ok) {
        throw new Error('주소 변환 실패')
      }

      const data = await response.json()

      if (data.documents && data.documents.length > 0) {
        // 행정동 정보 우선 사용
        const region = data.documents.find(d => d.region_type === 'H') || data.documents[0]
        // "서울특별시 강남구 역삼동" -> "역삼동"
        const dong = region.region_3depth_name || region.region_2depth_name
        return dong
      }

      return '현재 위치'
    } catch (err) {
      console.error('주소 변환 오류:', err)
      return '현재 위치'
    }
  }

  // GPS 위치 가져오기
  const getCurrentLocation = useCallback(async () => {
    setLoading(true)
    setError(null)

    // Geolocation API 지원 확인
    if (!navigator.geolocation) {
      setError('이 브라우저에서는 위치 서비스를 지원하지 않습니다.')
      setLocation(DEFAULT_LOCATION)
      setAddress(DEFAULT_LOCATION.address)
      setLoading(false)
      return
    }

    try {
      const position = await new Promise((resolve, reject) => {
        navigator.geolocation.getCurrentPosition(
          resolve,
          reject,
          {
            enableHighAccuracy: true,
            timeout: 10000,
            maximumAge: 300000 // 5분간 캐시 사용
          }
        )
      })

      const newLocation = {
        latitude: position.coords.latitude,
        longitude: position.coords.longitude
      }

      setLocation(newLocation)
      setPermissionDenied(false)

      // 주소 변환
      const addressName = await getAddressFromCoords(
        newLocation.latitude,
        newLocation.longitude
      )
      setAddress(addressName)

      console.log('위치 획득 성공:', newLocation, addressName)

    } catch (err) {
      console.error('위치 획득 실패:', err)

      if (err.code === 1) {
        // PERMISSION_DENIED
        setPermissionDenied(true)
        setError('위치 권한이 거부되었습니다. 설정에서 권한을 허용해주세요.')
      } else if (err.code === 2) {
        // POSITION_UNAVAILABLE
        setError('위치 정보를 사용할 수 없습니다.')
      } else if (err.code === 3) {
        // TIMEOUT
        setError('위치 정보 요청 시간이 초과되었습니다.')
      } else {
        setError('위치를 가져오는데 실패했습니다.')
      }

      // 기본 위치 사용
      setLocation(DEFAULT_LOCATION)
      setAddress(DEFAULT_LOCATION.address)
    } finally {
      setLoading(false)
    }
  }, [])

  // 앱 시작시 위치 가져오기
  useEffect(() => {
    getCurrentLocation()
  }, [getCurrentLocation])

  // 위치 새로고침
  const refreshLocation = () => {
    getCurrentLocation()
  }

  const value = {
    location,
    address,
    loading,
    error,
    permissionDenied,
    refreshLocation,
    // 편의 getter
    latitude: location?.latitude || DEFAULT_LOCATION.latitude,
    longitude: location?.longitude || DEFAULT_LOCATION.longitude
  }

  return (
    <LocationContext.Provider value={value}>
      {children}
    </LocationContext.Provider>
  )
}

export function useLocation() {
  const context = useContext(LocationContext)
  if (!context) {
    throw new Error('useLocation must be used within a LocationProvider')
  }
  return context
}

export default LocationContext
